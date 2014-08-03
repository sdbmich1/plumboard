class AddDirectUploadUrlToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :direct_upload_url, :string
    add_index :pictures, :processing
  end
end
