require 'net/http'
require "open-uri"
require 'open_uri_redirections'
require "nokogiri"
class Picture < ActiveRecord::Base
  include NameParse

  # Environment-specific direct upload url verifier screens for malicious posted upload locations.
  DIRECT_UPLOAD_URL_FORMAT = %r{\Ahttps:\/\/#{S3FileField.config.bucket}\.#{S3FileField.config.region}\.amazonaws\.com\/(?<path>uploads\/.+\/(?<filename>.+))\z}.freeze

  attr_accessible :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :photo, :processing, :photo_file_path,
    :direct_upload_url, :dup_flg
  
  has_attached_file :photo, {
       styles: { :large => "300x300>", :medium => "150x150>", :thumb => "100x100>", :small => "60x60>", :tiny => "30x30>" },
       convert_options: { :all => "-auto-orient" }
     }.merge(PAPERCLIP_STORAGE_OPTIONS)

  belongs_to :imageable, :polymorphic => true

  before_create :set_flg, if: :process_locally?
  before_create :set_page_attributes, if: :process_remotely?
  before_post_process :transliterate_file_name
  after_create :queue_processing, if: :process_remotely?
  after_update :queue_processing, if: :process_remotely?

  validates_attachment :photo, 
    :content_type => { :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp', 'image/tiff'] },
    :size => { :in => 0..MAX_PIXI_SIZE.megabytes }

  # ...and perform after save in background
  after_save do |picture| 
    if picture.processing && process_locally?
      processPhotoJob(picture)
    end
  end

  # Store an unescaped version of the escaped URL that Amazon returns from direct upload.
  def direct_upload_url=(escaped_url)
    write_attribute(:direct_upload_url, (CGI.unescape(escaped_url) rescue nil))
  end

  # Determines if file requires post-processing (image resizing, etc)
  def post_process_required?
    %r{^(image|(x-)?application)/(bmp|gif|jpeg|jpg|pjpeg|tif|png|x-png)$}.match(photo_content_type).present?
  end

  # process picture styles
  def processPhotoJob(picture)
    picture.regenerate_styles!
  end
  handle_asynchronously :processPhotoJob, :queue => 'images'

  # detect if our photo file has changed
  def photo_changed?
    self.photo_file_size_changed? || self.photo_file_name_changed? || self.photo_content_type_changed? || self.photo_updated_at_changed?
  end

  # set flg for background picture loading
  def set_flg
    self.processing = true
  end

  # set default url for missing pictures
  def set_default_url
    ActionController::Base.helpers.asset_path('star.jpg')
  end

  # remove space from filename
  def transliterate_file_name
    unless photo_file_name.blank?
      extension = File.extname(photo_file_name).gsub(/^\.+/, '') rescue nil
      if extension
        filename = photo_file_name.gsub(/\.#{extension}$/, '')
        self.photo.instance_write(:photo_file_name, "#{NameParse::transliterate(filename)}.#{NameParse::transliterate(extension)}"
          .gsub('//', '/'))
      end
    end
  end

  # generate styles (downloads original first)
  def regenerate_styles!
    return unless (!processing)
    self.photo.reprocess! 
    self.processing = false   
    self.save(validations: false)
  end

  # get url for json
  def photo_url
    photo.url rescue nil
  end 

  def as_json(options={})
    { :id=>self.id, :imageable_id=>self.imageable_id, :photo_file_name=>self.photo_file_name, :photo_url=>photo_url } 
  end

  # Final upload processing step
  def self.transfer_and_cleanup(id)
    pic = Picture.find(id)
    direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(pic.direct_upload_url)
    s3 = AWS::S3.new

    if pic.post_process_required?
      begin
        # url = pic.set_file_url(pic.direct_upload_url)
        pic.photo = URI.parse(URI.escape("#{pic.direct_upload_url}"))
      rescue URI::InvalidURIError
        host = url.match(".+\:\/\/([^\/]+)")[1]
	path = url.partition(host)[2] || "/"
	Net::HTTP.get host, path
      end
    else
      paperclip_file_path = "photos/#{id}/original/#{direct_upload_url_data[:filename]}"
      s3.buckets[S3FileField.config.bucket].objects[paperclip_file_path].copy_from(direct_upload_url_data[:path])
    end

    pic.processing = true
    pic.save

    s3.buckets[S3FileField.config.bucket].objects[direct_upload_url_data[:path]].delete
  end

  def self.parse_uri pic
  end

  # load image from s3 upload folder
  def picture_from_url
    response = open(direct_upload_url) rescue nil
    self.photo = URI.parse(direct_upload_url) if response rescue nil
  end

  # remove space from S3 direct_upload_url
  def set_file_url url
    return nil if url.blank?
    extension = File.extname(url).gsub(/^\.+/, '')
    filename = url.gsub(/\.#{extension}$/, '')
    "#{NameParse::parse_url(filename)}.#{NameParse::transliterate(extension)}" rescue url
  end

  protected

  # Set attachment attributes from the direct upload
  def set_page_attributes
    tries ||= 5
    direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(direct_upload_url)
    s3 = AWS::S3.new
    
    direct_upload_head = s3.buckets[S3FileField.config.bucket].objects[direct_upload_url_data[:path]].head rescue nil

    unless direct_upload_head.blank?
      self.photo_file_name     = direct_upload_url_data[:filename]
      self.photo_file_size     = direct_upload_head.content_length
      self.photo_content_type  = direct_upload_head.content_type
      self.photo_updated_at    = direct_upload_head.last_modified
    # self.photo_file_path    = direct_upload_head.photo_file_path
    end

  rescue AWS::S3::Errors::NoSuchKey => e
    tries -= 1
    if tries > 0
      sleep(3)
      retry
    else
      false
    end
  end

  # Queue file processing
  def queue_processing
    Picture.delay(:queue => 'images').transfer_and_cleanup(id)
  end

  # local processing
  def process_locally?
    USE_LOCAL_PIX.upcase == 'YES'
  end

  # remote processing
  def process_remotely?
    !Rails.env.test? && USE_LOCAL_PIX.upcase == 'NO' && !dup_flg
  end

end
