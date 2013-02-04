class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.integer :listing_id
      t.text :content

      t.timestamps
    end

    add_index :posts, [:user_id, :listing_id],                :unique => true
  end
end
