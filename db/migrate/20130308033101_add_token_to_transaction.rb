class AddTokenToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :token, :string
    add_column :transactions, :confirmation_no, :string
    add_index :transactions, :confirmation_no
  end
end
