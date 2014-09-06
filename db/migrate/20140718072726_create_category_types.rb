class CreateCategoryTypes < ActiveRecord::Migration
  def change
    create_table :category_types do |t|
      t.string :code
      t.string :status
      t.string :hide

      t.timestamps
    end
  end
end
