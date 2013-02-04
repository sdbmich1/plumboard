class AddUidDateIndexToPosts < ActiveRecord::Migration
  def change
    add_index :posts, [:user_id, :created_at],                :unique => true
  end
end
