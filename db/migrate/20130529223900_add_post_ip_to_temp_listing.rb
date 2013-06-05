class AddPostIpToTempListing < ActiveRecord::Migration
  def change
    add_column :temp_listings, :post_ip, :string
    add_column :listings, :post_ip, :string
  end
end
