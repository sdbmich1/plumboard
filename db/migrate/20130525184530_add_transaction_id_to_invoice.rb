class AddTransactionIdToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :transaction_id, :integer
    add_index :invoices, :transaction_id
  end
end
