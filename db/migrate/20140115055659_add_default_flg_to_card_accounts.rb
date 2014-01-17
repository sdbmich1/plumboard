class AddDefaultFlgToCardAccounts < ActiveRecord::Migration
  def change
    add_column :card_accounts, :default_flg, :string
    add_column :bank_accounts, :default_flg, :string

    add_index :card_accounts, :card_no
  end
end
