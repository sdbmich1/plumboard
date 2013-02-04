class CreateTransactionDetails < ActiveRecord::Migration
  def change
    create_table :transaction_details do |t|
      t.integer :transaction_id
      t.string :item_name
      t.integer :quantity
      t.float :price

      t.timestamps
    end
    add_index :transaction_details, :transaction_id
  end
end
