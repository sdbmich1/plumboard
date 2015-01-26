class AddItemTypeToListings < ActiveRecord::Migration
  def change
    add_column :listings, :item_type, :string
    add_column :listings, :size, :string
    add_column :temp_listings, :item_type, :string
    add_column :temp_listings, :size, :string
  end
end
