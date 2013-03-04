class CreateTempListings < ActiveRecord::Migration
  def change
    create_table :temp_listings do |t|
      t.string :title
      t.text :description
      t.string :status
      t.datetime :start_date
      t.datetime :end_date
      t.string :alias_name
      t.integer :category_id
      t.integer :site_id
      t.integer :seller_id
      t.integer :transaction_id
      t.integer :buyer_id
      t.float :price
      t.string :show_alias_flg
      t.string :show_phone_flg

      t.timestamps
    end
  end
end
