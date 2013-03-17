class AddEditedByToTempListing < ActiveRecord::Migration
  def change
    add_column :temp_listings, :edited_by, :string
    add_column :temp_listings, :edited_dt, :datetime
    add_column :listings, :edited_by, :string
    add_column :listings, :edited_dt, :datetime
  end
end
