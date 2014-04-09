class AddStatusToSavedListings < ActiveRecord::Migration
  def change
    add_column :saved_listings, :status, :string
    add_index :saved_listings, :status
  end
end
