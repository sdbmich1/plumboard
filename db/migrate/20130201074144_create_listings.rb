class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.string :title
      t.integer :category_id
      t.text :description
      t.string :status
      t.integer :seller_id
      t.integer :buyer_id
      t.float :price
      t.string :show_alias_flg
      t.string :show_phone_flg

      t.timestamps
    end
  end
end
