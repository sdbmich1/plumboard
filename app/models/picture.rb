class Picture < ActiveRecord::Base
  attr_accessible :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :photo
  has_attached_file :photo,
	  url: "/system/:class/:attachment/:id/:style/:filename",
	  path: ":rails_root/public/system/:class/:attachment/:id_partition/:style/:filename"

  belongs_to :imageable, :polymorphic => true

  validates_attachment :photo, :presence => true,
    :content_type => { :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp'] },
    :size => { :in => 0..1.megabytes }

  def set_default_url
    ActionController::Base.helpers.asset_path('star.jpg')
  end
end
