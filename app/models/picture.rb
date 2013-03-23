class Picture < ActiveRecord::Base
  attr_accessible :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :photo, :delete_photo, :delete_flg
  
  has_attached_file :photo,
	  url: "/system/:class/:attachment/:id/:style/:filename",
	  path: ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename"    

  belongs_to :imageable, :polymorphic => true

  before_save :destroy_photo

  validates_attachment :photo, 
    :content_type => { :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp'] },
    :size => { :in => 0..1.megabytes }

  def set_default_url
    ActionController::Base.helpers.asset_path('star.jpg')
  end

  def delete_photo
    @delete_photo ||= "0"
  end

  def delete_photo=(value)
    @delete_photo = value
  end
  
  protected

  def destroy_photo
    self.photo.clear if @delete_photo == "1" #&& !self.photo.dirty?
  end
end
