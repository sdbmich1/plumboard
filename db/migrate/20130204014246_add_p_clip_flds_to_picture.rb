class AddPClipFldsToPicture < ActiveRecord::Migration
  def change
    add_column :pictures, :photo_file_name, :string
    add_column :pictures, :photo_content_type, :string
    add_column :pictures, :photo_file_size, :integer
    add_column :pictures, :photo_updated_at, :datetime
  end
end
