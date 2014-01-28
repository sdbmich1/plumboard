class AddPixanIdToListings < ActiveRecord::Migration
  def change
    add_column :listings, :pixan_id, :integer
    add_index :listings, :pixan_id
    add_column :temp_listings, :pixan_id, :integer
    add_index :temp_listings, :pixan_id
    add_column :old_listings, :pixan_id, :integer
    add_index :old_listings, :pixan_id
  end
end
