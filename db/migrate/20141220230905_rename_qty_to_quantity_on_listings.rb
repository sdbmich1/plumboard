class RenameQtyToQuantityOnListings < ActiveRecord::Migration
  def up
    rename_column :listings, :qty, :quantity
    rename_column :temp_listings, :qty, :quantity
  end

  def down
    rename_column :listings, :quantity, :qty
    rename_column :temp_listings, :quantity, :qty
  end
end
