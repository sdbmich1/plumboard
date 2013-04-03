class AddFldsToPost < ActiveRecord::Migration
  def change
    add_column :posts, :pixi_id, :string
    add_column :posts, :recipient_id, :integer
    add_index :posts, :pixi_id
  end
end
