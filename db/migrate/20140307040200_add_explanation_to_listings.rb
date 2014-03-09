class AddExplanationToListings < ActiveRecord::Migration
  def change
    add_column :listings, :explanation, :string
    add_column :temp_listings, :explanation, :string
    add_column :old_listings, :explanation, :string
  end
end
