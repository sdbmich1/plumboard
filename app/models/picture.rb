class Picture < ActiveRecord::Base
  attr_accessible :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :photo, :processing, :photo_file_path,
    :direct_upload_url, :dup_flg
  
  has_attached_file :photo, {
    styles: lambda { |attachment| attachment.instance.image_options[:styles] }, 
    convert_options: { :all => "-auto-orient -enhance" }
  }.merge(PAPERCLIP_STORAGE_OPTIONS)

  belongs_to :imageable, :polymorphic => true

  before_create :set_flg, if: :process_locally?
  after_create :set_page_attributes, if: :process_remotely?
  before_post_process :transliterate_file_name
  after_save :queue_processing, if: :process_remotely?

  validates_attachment :photo, 
    :content_type => { :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp', 'image/tiff'] },
    :size => { :in => 0..MAX_PIXI_SIZE.megabytes }

  # ...and perform after save in background
  after_save do |picture| 
    processPhotoJob(picture) if picture.processing && process_locally?
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
    PictureProcessor.new(self).transliterate_file_name
  end

  # generate styles (downloads original first)
  def regenerate_styles!
    PictureProcessor.new(self).regenerate_styles!
  end

  # get url for json
  def photo_url
    photo.url rescue nil
  end 

  def as_json(options={})
    { :id=>self.id, :imageable_id=>self.imageable_id, :photo_file_name=>self.photo_file_name, :photo_url=>photo_url } 
  end

  # load image from s3 upload folder
  def picture_from_url
    PictureProcessor.new(self).picture_from_url
  end

  # remove space from S3 direct_upload_url
  def set_file_url url
    PictureProcessor.new(self).set_file_url url
  end

  def image_options
    PictureProcessor.new(self).image_options
  end

  protected

  # Set attachment attributes from the direct upload
  def set_page_attributes
    PictureProcessor.new(self).set_page_attributes
  end

  # Queue file processing
  def queue_processing
    PictureProcessor.new(self).delay(:queue => 'images').transfer_and_cleanup(id) if processing
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
