class AddEventTypeCodeToListings < ActiveRecord::Migration
  def change
    add_column :listings, :event_type_code, :string
    add_index :listings, :event_type_code
  end
end
