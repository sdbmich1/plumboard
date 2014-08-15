class AddEventTypeCodeToTempListings < ActiveRecord::Migration
  def change
    add_column :temp_listings, :event_type_code, :string
    add_index :temp_listings, :event_type_code
  end
end
