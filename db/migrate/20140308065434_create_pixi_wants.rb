class CreatePixiWants < ActiveRecord::Migration
  def change
    create_table :pixi_wants do |t|
      t.integer :user_id
      t.string :pixi_id

      t.timestamps
    end
    add_index :pixi_wants, [:user_id, :pixi_id]
  end
end
