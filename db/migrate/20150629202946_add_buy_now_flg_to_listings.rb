class AddBuyNowFlgToListings < ActiveRecord::Migration
  def change
    add_column :listings, :buy_now_flg, :boolean
    add_column :temp_listings, :buy_now_flg, :boolean
    add_column :old_listings, :buy_now_flg, :boolean
  end
end
