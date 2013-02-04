class Picture < ActiveRecord::Base
  belongs_to :imageable, :polymorphic => true
  has_attached_file :photo

  attr_accessible :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at, :photo
  attr_accessor :photo_file_name, :photo_content_type, :photo_file_size, :photo_updated_at
  validates_attachment_presence :photo
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/bmp']
end
