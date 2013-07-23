class Picture < ActiveRecord::Base
  include NameParse
  attr_accessible :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :photo
  
  has_attached_file :photo, {
	  styles: { :large => "300x300>", :medium => "150x150>", :thumb => "100x100>", :small => "60x60>", :tiny => "30x30>" }
     }.merge(PAPERCLIP_STORAGE_OPTIONS)

  belongs_to :imageable, :polymorphic => true

  before_post_process :transliterate_file_name

  validates_attachment :photo, 
    :content_type => { :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp'] },
    :size => { :in => 0..1.megabytes }

  private

  def set_default_url
    ActionController::Base.helpers.asset_path('star.jpg')
  end

  # remove space from filename
  def transliterate_file_name
    extension = File.extname(photo_file_name).gsub(/^\.+/, '')
    filename = photo_file_name.gsub(/\.#{extension}$/, '')
    self.photo.instance_write(:file_name, "#{NameParse::transliterate(filename)}.#{NameParse::transliterate(extension)}")
  end
end
