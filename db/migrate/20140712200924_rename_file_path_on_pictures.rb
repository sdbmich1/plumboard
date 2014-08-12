class RenameFilePathOnPictures < ActiveRecord::Migration
  def up
    rename_column :pictures, :file_path, :photo_file_path
  end

  def down
  end
end
