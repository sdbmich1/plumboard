class AddAttachmentPhotoToPictures < ActiveRecord::Migration
  def self.up
    change_table :pictures do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :pictures, :photo
  end
end
