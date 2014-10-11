class RemoveTempListingIndexes < ActiveRecord::Migration
  def up
    remove_index :temp_listings, column: [:event_type_code]
    remove_index :temp_listings, column: [:parent_pixi_id]
    remove_index :temp_listings, column: [:pixan_id]
  end

  def down
    add_index :temp_listings, [:event_type_code]
    add_index :temp_listings, [:parent_pixi_id]
    add_index :temp_listings, [:pixan_id]
  end
end
