class AddPromoCodeToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :promo_code, :string
  end
end
