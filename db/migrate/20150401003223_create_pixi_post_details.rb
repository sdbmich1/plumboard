class CreatePixiPostDetails < ActiveRecord::Migration
  def change
    create_table :pixi_post_details do |t|
      t.integer :pixi_post_id
      t.string :pixi_id

      t.timestamps
    end
    add_index :pixi_post_details, [:pixi_post_id, :pixi_id]
    add_index :pixi_post_details, :pixi_id
  end
end
