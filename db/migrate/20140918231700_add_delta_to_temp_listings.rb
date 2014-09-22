class AddDeltaToTempListings < ActiveRecord::Migration
  def change
    add_column :temp_listings, :delta, :boolean
  end
end
