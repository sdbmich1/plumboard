class CreateOldListings < ActiveRecord::Migration
  def change
    create_table :old_listings do |t|
      t.string :title
      t.integer :user_id
      t.string :pixi_id
      t.integer :category_id
      t.text :description
      t.string :status
      t.integer :seller_id
      t.integer :buyer_id
      t.float :price
      t.string :show_alias_flg
      t.string :show_phone_flg
      t.string :alias_name
      t.datetime :start_date
      t.datetime :end_date
      t.integer :site_id
      t.integer :transaction_id
      t.string :edited_by
      t.datetime :edited_dt
      t.string :post_ip
      t.string :compensation
      t.float :lng
      t.float :lat
      t.datetime :event_start_date
      t.datetime :event_end_date
      t.datetime :event_start_time
      t.datetime :event_end_time
      t.integer :year_built

      t.timestamps
    end
    add_index :old_listings, :title
    add_index :old_listings, :user_id
    add_index :old_listings, :pixi_id
    add_index :old_listings, :category_id
  end
end
