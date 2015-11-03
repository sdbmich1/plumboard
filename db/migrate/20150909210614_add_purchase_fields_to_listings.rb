class AddPurchaseFieldsToListings < ActiveRecord::Migration
  def change
    [:listings, :temp_listings, :old_listings].each do |table|
      add_column table, :est_ship_cost, :float
      add_column table, :sales_tax, :float
      add_column table, :fulfillment_type_code, :string
      add_index table, :fulfillment_type_code
    end
  end
end
