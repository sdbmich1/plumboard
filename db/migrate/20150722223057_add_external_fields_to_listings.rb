class AddExternalFieldsToListings < ActiveRecord::Migration
  def change
    add_column :listings, :external_url, :string
    add_column :listings, :ref_id, :integer
    add_index :listings, :ref_id
    add_column :temp_listings, :external_url, :string
    add_column :temp_listings, :ref_id, :integer
    add_column :old_listings, :external_url, :string
    add_column :old_listings, :ref_id, :integer
  end
end
