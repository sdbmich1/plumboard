class ChangeColumnImageableOnPictures < ActiveRecord::Migration
  def up
    drop_table :pictures
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, :polymorphic => true

      t.timestamps
    end
  end

  def down
  end
end
