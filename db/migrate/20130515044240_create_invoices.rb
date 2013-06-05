class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :pixi_id
      t.integer :seller_id
      t.integer :buyer_id
      t.integer :quantity
      t.float :price
      t.float :amount
      t.text :comment

      t.timestamps
    end

    add_index :invoices, [:pixi_id, :buyer_id, :seller_id]
  end
end
