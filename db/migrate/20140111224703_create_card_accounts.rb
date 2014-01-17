class CreateCardAccounts < ActiveRecord::Migration
  def change
    create_table :card_accounts do |t|
      t.string :token
      t.string :card_number
      t.string :card_type
      t.integer :expiration_month
      t.integer :expiration_year
      t.string :status
      t.integer :user_id
      t.string :description

      t.timestamps
    end
     
    add_index :card_accounts, :user_id
  end
end
