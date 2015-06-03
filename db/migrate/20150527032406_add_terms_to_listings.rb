class AddTermsToListings < ActiveRecord::Migration
  def change
    add_column :listings, :term, :string
    add_column :listings, :avail_date, :datetime
    add_column :temp_listings, :term, :string
    add_column :temp_listings, :avail_date, :datetime
    add_column :old_listings, :term, :string
    add_column :old_listings, :avail_date, :datetime
    add_index :listings, :term
    add_index :listings, :avail_date
  end
end
