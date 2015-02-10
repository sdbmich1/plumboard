class AddIndexOnImgFieldsForPictures < ActiveRecord::Migration
  def up
    add_index :pictures, [:imageable_id, :imageable_type]
  end

  def down
    remove_index :pictures, :column => [:imageable_id, :imageable_type]
  end
end
