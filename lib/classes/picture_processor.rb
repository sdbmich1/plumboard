require "open-uri"
require 'open_uri_redirections'
require "nokogiri"
class PictureProcessor
  include NameParse

  # Environment-specific direct upload url verifier screens for malicious posted upload locations.
  DIRECT_UPLOAD_URL_FORMAT = %r{\Ahttps:\/\/#{S3FileField.config.bucket}\.#{S3FileField.config.region}\.amazonaws\.com\/(?<path>uploads\/.+\/(?<filename>.+))\z}.freeze

  def initialize pic
    @pic = pic
  end

  # remove space from filename
  def transliterate_file_name
    unless @pic.photo_file_name.blank?
      extension = File.extname(@pic.photo_file_name).gsub(/^\.+/, '') rescue nil
      if extension
        filename = @pic.photo_file_name.gsub(/\.#{extension}$/, '')
        @pic.photo.instance_write(:photo_file_name, "#{NameParse::transliterate(filename)}.#{NameParse::transliterate(extension)}".gsub('//', '/'))
      end
    end
  end

  # load image from s3 upload folder
  def picture_from_url
    response = open(@pic.direct_upload_url) rescue nil
    @pic.photo = URI.parse(@pic.direct_upload_url) if response rescue nil
  end

  # Final upload processing step
  def transfer_and_cleanup(id)
    pic = Picture.find(id)
    if pic 
      direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(pic.direct_upload_url)
      s3 = AWS::S3.new

      if pic.post_process_required?
        pic.photo = URI.parse(URI.escape(pic.direct_upload_url)) 
      else
        paperclip_file_path = "photos/#{id}/original/#{direct_upload_url_data[:filename]}"
        s3.buckets[S3FileField.config.bucket].objects[paperclip_file_path].copy_from(direct_upload_url_data[:path])
      end

      pic.processing = false
      pic.save
      s3.buckets[S3FileField.config.bucket].objects[direct_upload_url_data[:path]].delete
    end
  end

  # remove space from S3 direct_upload_url
  def set_file_url url
    return nil if url.blank?
    extension = File.extname(url).gsub(/^\.+/, '')
    filename = url.gsub(/\.#{extension}$/, '')
    "#{NameParse::parse_url(filename)}.#{NameParse::transliterate(extension)}" rescue url
  end

  # Set attachment attributes from the direct upload
  def set_page_attributes
    tries ||= 5

    @pic.processing = !@pic.direct_upload_url.blank?
    @pic.direct_upload_url ||= @pic.photo.url
    direct_upload_url_data = DIRECT_UPLOAD_URL_FORMAT.match(@pic.direct_upload_url)
    s3 = AWS::S3.new
    
    direct_upload_head = s3.buckets[S3FileField.config.bucket].objects[direct_upload_url_data[:path]].head rescue nil

    unless direct_upload_head.blank?
      @pic.photo_file_name     = direct_upload_url_data[:filename]
      @pic.photo_file_size     = direct_upload_head.content_length
      @pic.photo_content_type  = direct_upload_head.content_type
      @pic.photo_updated_at    = direct_upload_head.last_modified
    # @pic.photo_file_path    = direct_upload_head.photo_file_path
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

  # generate styles (downloads original first)
  def regenerate_styles!
    return unless @pic.processing
    @pic.processing = false
    @pic.photo.reprocess! 
  end

  def image_options
    case @pic.imageable_type 
    when 'User', 'Site'
      { styles: { :medium => "180x180!", :thumb => "125x125>", :small => "60x60>", :tiny => "30x30>", :cover => "1280x200!" }}
    when 'Category'
      { styles: { :medium => "180x180>", :thumb => "125x125>", :small => "60x60>", :tiny => "30x30>"}} 
    when 'Listing', 'TempListing'
      { styles: { :large => "550x450>", :preview => "200x200>", :medium => "180x180>", :thumb => "125x125>", :small => "60x60>", :tiny => "30x30>"}}
    else
      { styles: { :large => "550x450>", :medium => "180x180>", :thumb => "125x125>", :small => "60x60>", :tiny => "30x30>"}}
    end
  end
end

