class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :pixi_id
      t.integer :user_id
      t.text :content

      t.timestamps
    end
    add_index :comments, :pixi_id
  end
end
