class AddIndexOnAcctTokenOnUsers < ActiveRecord::Migration
  def up
    add_index :users, :acct_token
  end

  def down
    remove_index :users, :acct_token
  end
end
