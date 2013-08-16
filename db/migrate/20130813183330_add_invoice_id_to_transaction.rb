class AddInvoiceIdToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :invoice_id, :integer
    add_index :transactions, :invoice_id
  end
end
