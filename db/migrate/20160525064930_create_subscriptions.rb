class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :plan_id
      t.integer :user_id
      t.integer :card_account_id
      t.string :stripe_id
      t.string :status

      t.timestamps null: false
    end
  end
end
