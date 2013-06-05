class RemoveListingIdIndexOnPosts < ActiveRecord::Migration
  def up
    remove_index :posts, :column => [:user_id,:listing_id]
  end

  def down
  end
end
