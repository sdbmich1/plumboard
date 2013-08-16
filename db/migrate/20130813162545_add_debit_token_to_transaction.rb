class AddDebitTokenToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :debit_token, :string
    remove_column :posts, :listing_id
  end
end
