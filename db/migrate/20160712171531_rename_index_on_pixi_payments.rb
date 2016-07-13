class RenameIndexOnPixiPayments < ActiveRecord::Migration
  def change
    rename_index :pixi_payments, 'index_pixi_payments_on_pixi_id_and_transaction_id_and_invoice_id', 'index_pixi_payments_on_pid_txn_id_inv_id'
  end
end
