class CreatePictures < ActiveRecord::Migration
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable

      t.timestamps
    end
    add_index :pictures, :imageable_id
  end
end
