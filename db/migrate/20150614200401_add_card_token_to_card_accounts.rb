class AddCardTokenToCardAccounts < ActiveRecord::Migration
  def change
    add_column :card_accounts, :card_token, :string
  end
end
