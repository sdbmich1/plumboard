class AddBankAccountIdToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :bank_account_id, :integer
    add_index :invoices, :bank_account_id
  end
end
