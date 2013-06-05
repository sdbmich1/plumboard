class AddSalesTaxToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :sales_tax, :float
    add_column :invoices, :inv_date, :datetime

    add_index :invoices, :status
  end
end
