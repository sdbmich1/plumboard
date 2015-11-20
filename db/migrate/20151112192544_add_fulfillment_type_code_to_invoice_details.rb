class AddFulfillmentTypeCodeToInvoiceDetails < ActiveRecord::Migration
  def change
    add_column :invoice_details, :fulfillment_type_code, :string
  end
end
