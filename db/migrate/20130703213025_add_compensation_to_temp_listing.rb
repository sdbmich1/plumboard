class AddCompensationToTempListing < ActiveRecord::Migration
  def change
    add_column :temp_listings, :compensation, :string
    add_column :listings, :compensation, :string
  end
end
