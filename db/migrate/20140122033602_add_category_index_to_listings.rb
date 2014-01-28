class AddCategoryIndexToListings < ActiveRecord::Migration
  def change
    add_index :listings, :category_id
  end
end
