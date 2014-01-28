class AddStatusToPixiPosts < ActiveRecord::Migration
  def change
    add_column :pixi_posts, :status, :string
  end
end
