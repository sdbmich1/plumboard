class AddHousingFieldsToListings < ActiveRecord::Migration
  def change
    add_column :listings, :bed_no, :integer
    add_column :listings, :bath_no, :integer
    add_column :temp_listings, :bed_no, :integer
    add_column :temp_listings, :bath_no, :integer
    add_column :old_listings, :bed_no, :integer
    add_column :old_listings, :bath_no, :integer
  end
end
