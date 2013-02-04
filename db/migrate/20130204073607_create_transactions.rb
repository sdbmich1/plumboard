class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :first_name
      t.string :last_name
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :email
      t.string :home_phone
      t.string :work_phone
      t.integer :credit_card_no
      t.string :promo_code
      t.string :country
      t.string :payment_type
      t.string :code
      t.string :description
      t.float :amt

      t.timestamps
    end
    add_index :transactions, :code
  end
end
