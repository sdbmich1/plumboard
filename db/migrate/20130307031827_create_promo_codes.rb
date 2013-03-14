class CreatePromoCodes < ActiveRecord::Migration
  def change
    create_table :promo_codes do |t|
      t.string :code
      t.string :promo_name
      t.string :description
      t.date :start_date
      t.date :end_date
      t.time :start_time
      t.time :end_time
      t.string :status
      t.integer :max_redemptions
      t.integer :amountOff
      t.integer :percentOff
      t.string :currency

      t.timestamps
    end
    add_index :promo_codes, [:code, :status]
    add_index :promo_codes, [:end_date, :start_date]

  end
end
