class AddInvoiceDetailsCountToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :invoice_details_count, :integer
  end
end
