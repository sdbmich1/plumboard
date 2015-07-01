class AddBizFieldsToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :buy_now_flg, :boolean
    add_column :preferences, :sales_tax, :float
    add_column :preferences, :ship_amt, :float
    add_column :preferences, :fulfillment_type_code, :string
  end
end
