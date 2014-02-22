class CreatePixiLikes < ActiveRecord::Migration
  def change
    create_table :pixi_likes do |t|
      t.integer :user_id
      t.string :pixi_id

      t.timestamps
    end
    add_index :pixi_likes, [:user_id, :pixi_id]
  end
end
