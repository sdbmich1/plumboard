class AddShipFldsToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :recipient_first_name, :string
    add_column :transactions, :recipient_last_name, :string
    add_column :transactions, :recipient_email, :string
    add_column :transactions, :ship_address, :string
    add_column :transactions, :ship_address2, :string
    add_column :transactions, :ship_city, :string
    add_column :transactions, :ship_state, :string
    add_column :transactions, :ship_zip, :string
    add_column :transactions, :ship_country, :string
    add_column :transactions, :recipient_phone, :string
  end
end
