class RenamePostsCountToActivePostsCountOnConversations < ActiveRecord::Migration
  def up
    rename_column :conversations, :posts_count, :active_posts_count
  end

  def down
    rename_column :conversations, :active_posts_count, :posts_count
  end
end
