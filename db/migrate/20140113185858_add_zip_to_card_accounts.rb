class AddZipToCardAccounts < ActiveRecord::Migration
  def change
    add_column :card_accounts, :zip, :string
  end
end
