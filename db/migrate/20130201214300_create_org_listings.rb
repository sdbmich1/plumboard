class CreateOrgListings < ActiveRecord::Migration
  def change
    create_table :org_listings do |t|
      t.integer :org_id
      t.integer :listing_id

      t.timestamps
    end

    add_index :org_listings, [:org_id, :listing_id], :unique => true
  end
end
