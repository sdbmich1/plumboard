class AddEventTimesToTempListing < ActiveRecord::Migration
  def change
    add_column :temp_listings, :event_start_time, :datetime
    add_column :temp_listings, :event_end_time, :datetime
    add_column :listings, :event_start_time, :datetime
    add_column :listings, :event_end_time, :datetime
  end
end
