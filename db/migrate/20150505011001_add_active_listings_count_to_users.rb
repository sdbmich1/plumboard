class AddActiveListingsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active_listings_count, :integer, default: 0
  end
end
