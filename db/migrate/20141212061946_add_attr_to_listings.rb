class AddAttrToListings < ActiveRecord::Migration
  def change
    add_column :listings, :condition_type_code, :string
    add_index :listings, :condition_type_code
    add_column :listings, :color, :string
    add_column :listings, :qty, :integer
    add_column :listings, :mileage, :integer
    add_column :listings, :other_id, :string
    add_column :temp_listings, :condition_type_code, :string
    add_index :temp_listings, :condition_type_code
    add_column :temp_listings, :color, :string
    add_column :temp_listings, :qty, :integer
    add_column :temp_listings, :mileage, :integer
    add_column :temp_listings, :other_id, :string
  end
end
