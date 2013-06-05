class AddTaxToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :subtotal, :float
    add_column :invoices, :tax_total, :float
  end
end
