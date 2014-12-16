class AddIndexOnUpdatedAtOnTransactions < ActiveRecord::Migration
  def up
  	add_index :transactions, :updated_at
  end

  def down
  	remove_index :transactions, :updated_at
  end
end
