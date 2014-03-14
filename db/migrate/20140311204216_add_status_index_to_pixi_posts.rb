class AddStatusIndexToPixiPosts < ActiveRecord::Migration
  def change
    add_index :pixi_posts, :status
  end
end
