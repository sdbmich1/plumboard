class AddFilePathToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :file_path, :string
  end
end
