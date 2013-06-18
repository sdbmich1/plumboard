class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.string :token
      t.integer :user_id
      t.integer :acct_no
      t.string :acct_name
      t.string :acct_type
      t.string :status

      t.timestamps
    end
    add_index :bank_accounts, :user_id
  end
end
