class AddDeltaFlgToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :delta, :boolean
    add_column :listings, :delta, :boolean
  end
end
