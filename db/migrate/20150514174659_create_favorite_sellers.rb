class CreateFavoriteSellers < ActiveRecord::Migration
  def change
    create_table :favorite_sellers do |t|
      t.integer :user_id
      t.integer :seller_id
      t.string :status

      t.timestamps
    end
    add_index :favorite_sellers, :user_id
    add_index :favorite_sellers, :seller_id
  end
end
