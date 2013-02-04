class AddFldsToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :user_id, :integer
    add_index :transactions, :user_id
  end
end
