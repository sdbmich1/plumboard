class ChangeAcctNoOnBankAccount < ActiveRecord::Migration
  def up
    change_column :bank_accounts, :acct_no, :string
  end

  def down
  end
end
