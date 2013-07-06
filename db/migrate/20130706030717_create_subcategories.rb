class CreateSubcategories < ActiveRecord::Migration
  def change
    create_table :subcategories do |t|
      t.string :name
      t.integer :category_id
      t.string :status
      t.string :subcategory_type

      t.timestamps
    end
    add_index :subcategories, :category_id
  end
end
