class ChangeStartDateOnListing < ActiveRecord::Migration
  def up
    change_column :listings, :start_date, :datetime
    add_column :listings, :end_date, :datetime
    add_index :listings, [:end_date, :start_date]
  end

  def down
  end
end
