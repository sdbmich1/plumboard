class AddFieldsToBankAccounts < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :currency_type_code, :string
    add_column :bank_accounts, :country_code, :string
  end
end
