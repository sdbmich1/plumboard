class AddPixiIdIndexToListing < ActiveRecord::Migration
  def change
    add_index :listings, :pixi_id, unique: true
    add_index :temp_listings, :pixi_id, unique: true
    add_index :temp_listings, :status
    add_index :listings, :status
  end
end
