class AddRepostFlgToListings < ActiveRecord::Migration
  def change
    add_column :listings, :repost_flg, :boolean
    add_column :temp_listings, :repost_flg, :boolean
  end
end
