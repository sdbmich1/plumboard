class RemoveInvoiceIdFromTransaction < ActiveRecord::Migration
  def up
    remove_column :transactions, :invoice_id
  end

  def down
  end
end
