class CreateInvoiceDetails < ActiveRecord::Migration
  def change
    create_table :invoice_details do |t|
      t.integer :invoice_id
      t.string :pixi_id
      t.integer :quantity
      t.float :price
      t.float :subtotal

      t.timestamps
    end
    add_index :invoice_details, [:invoice_id, :pixi_id]
    add_index :invoice_details, :pixi_id
  end
end
