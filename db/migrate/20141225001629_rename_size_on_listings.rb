class RenameSizeOnListings < ActiveRecord::Migration
  def up
    rename_column :listings, :size, :item_size
    rename_column :temp_listings, :size, :item_size
  end

  def down
  end
end
