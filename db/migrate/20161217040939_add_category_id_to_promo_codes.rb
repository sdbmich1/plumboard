class AddCategoryIdToPromoCodes < ActiveRecord::Migration
  def change
    add_column :promo_codes, :category_id, :integer
    add_index :promo_codes, :category_id
    add_column :promo_codes, :subcategory_id, :integer
    add_index :promo_codes, :subcategory_id
  end
end
