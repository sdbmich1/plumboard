class AddYmmToTempListing < ActiveRecord::Migration
  def change
    add_column :temp_listings, :year_built, :integer
    add_column :listings, :year_built, :integer
  end
end
