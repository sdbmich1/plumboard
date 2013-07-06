class AddLongLatToTempListing < ActiveRecord::Migration
  def change
    add_column :temp_listings, :lng, :float
    add_column :temp_listings, :lat, :float
    add_column :temp_listings, :event_start_date, :datetime
    add_column :temp_listings, :event_end_date, :datetime

    add_column :listings, :lng, :float
    add_column :listings, :lat, :float
    add_column :listings, :event_start_date, :datetime
    add_column :listings, :event_end_date, :datetime

    rename_column :contacts, :long, :lng

    add_index :listings, [:lng, :lat]
    add_index :listings, [:event_start_date, :event_end_date]
  end
end
