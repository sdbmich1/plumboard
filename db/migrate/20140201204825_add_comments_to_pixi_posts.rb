class AddCommentsToPixiPosts < ActiveRecord::Migration
  def change
    add_column :pixi_posts, :comments, :text
    add_column :pixi_posts, :editor_id, :integer
    add_index :pixi_posts, :editor_id
  end
end
