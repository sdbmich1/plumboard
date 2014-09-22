class AddShipAmtToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :ship_amt, :float
    add_column :invoices, :other_amt, :float
  end
end
