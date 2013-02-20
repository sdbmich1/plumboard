class AddAttachmentToPicture < ActiveRecord::Migration
  def change
    drop_attached_file :pictures, :photo
    add_attachment :pictures, :photo
  end
end
