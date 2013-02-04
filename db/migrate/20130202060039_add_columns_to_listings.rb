class AddColumnsToListings < ActiveRecord::Migration
  def change
    add_column :listings, :start_date, :date
    add_column :listings, :org_id, :integer
    add_index :listings, [:org_id, :seller_id, :start_date]
  end
end
