class AddPhotoProcessingToPicture < ActiveRecord::Migration
  def change
    add_column :pictures, :photo_processing, :boolean
  end
end
