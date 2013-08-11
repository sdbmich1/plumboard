class ChangePhotoProcessingToProcessingOnPicture < ActiveRecord::Migration
  def up
    rename_column :pictures, :photo_processing, :processing
  end

  def down
  end
end
