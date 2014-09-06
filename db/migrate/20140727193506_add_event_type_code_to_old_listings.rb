class AddEventTypeCodeToOldListings < ActiveRecord::Migration
  def change
    add_column :old_listings, :event_type_code, :string
    add_index :old_listings, :event_type_code
  end
end
