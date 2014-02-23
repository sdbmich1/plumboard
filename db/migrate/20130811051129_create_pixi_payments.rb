class CreatePixiPayments < ActiveRecord::Migration
  def change
    create_table :pixi_payments do |t|
      t.string :pixi_id
      t.integer :transaction_id
      t.integer :invoice_id
      t.string :token
      t.integer :seller_id
      t.integer :buyer_id
      t.float :amount
      t.float :pixi_fee

      t.timestamps
    end

    add_index :pixi_payments, [:pixi_id, :transaction_id, :invoice_id]
    add_index :pixi_payments, [:pixi_id, :seller_id, :buyer_id]
  end
end
