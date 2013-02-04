class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.string :category_type
      t.string :status

      t.timestamps
    end
  end
end
