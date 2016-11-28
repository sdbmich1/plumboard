class CreatePromoCodeUsers < ActiveRecord::Migration
  def change
    create_table :promo_code_users do |t|
      t.integer :promo_code_id
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :promo_code_users, :promo_code_id
    add_index :promo_code_users, :user_id
  end
end
