class RenameCardTokenOnUsers < ActiveRecord::Migration
  def up
    rename_column :users, :card_token, :acct_token
  end

  def down
    rename_column :users, :acct_token, :card_token
  end
end
