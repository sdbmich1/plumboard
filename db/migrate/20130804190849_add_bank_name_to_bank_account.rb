class AddBankNameToBankAccount < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :bank_name, :string
  end
end
