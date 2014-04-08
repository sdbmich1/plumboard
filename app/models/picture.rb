class Picture < ActiveRecord::Base
  include NameParse
  attr_accessible :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :photo, :processing
  
  has_attached_file :photo, {
       styles: { :large => "300x300>", :medium => "150x150>", :thumb => "100x100>", :small => "60x60>", :tiny => "30x30>" }
     }.merge(PAPERCLIP_STORAGE_OPTIONS)

  belongs_to :imageable, :polymorphic => true

  before_create :set_flg
  before_post_process :transliterate_file_name

  validates_attachment :photo, 
    :content_type => { :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp'] },
    :size => { :in => 0..5.megabytes }

  # ...and perform after save in background
  after_save do |picture| 
    if picture.processing && !Rails.env.test?
      processPhotoJob(picture)
    end
  end

  # process picture styles
  def processPhotoJob(picture)
    picture.regenerate_styles!
  end
  handle_asynchronously :processPhotoJob

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
    extension = File.extname(photo_file_name).gsub(/^\.+/, '')
    filename = photo_file_name.gsub(/\.#{extension}$/, '')
    self.photo.instance_write(:file_name, "#{NameParse::transliterate(filename)}.#{NameParse::transliterate(extension)}".gsub('//', '/'))
  end

  # generate styles (downloads original first)
  def regenerate_styles!
    self.photo.reprocess! 
    self.processing = false   
    self.save(validations: false)
  end

  # get url for json
  def photo_url
    photo.url
  end 

  def as_json(options={})
    { :id=>self.id, :imageable_id=>self.imageable_id, :photo_file_name=>self.photo_file_name, :photo_url=>photo_url } 
  end
end
