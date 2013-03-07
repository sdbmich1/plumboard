class AddPixiIdToListing < ActiveRecord::Migration
  def change
    add_column :listings, :pixi_id, :string
    add_column :temp_listings, :pixi_id, :string
    add_column :temp_listings, :parent_pixi_id, :string

    add_index :temp_listings, :parent_pixi_id
  end
end
