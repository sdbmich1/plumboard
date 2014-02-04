class AddAddress2ToPixiPosts < ActiveRecord::Migration
  def change
    add_column :pixi_posts, :address2, :string
  end
end
