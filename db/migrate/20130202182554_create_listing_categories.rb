class CreateListingCategories < ActiveRecord::Migration
  def change
    create_table :listing_categories do |t|
      t.integer :category_id
      t.integer :listing_id

      t.timestamps
    end
    add_index :listing_categories, [:category_id, :listing_id]
  end
end
