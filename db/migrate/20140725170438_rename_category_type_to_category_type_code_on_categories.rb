class RenameCategoryTypeToCategoryTypeCodeOnCategories < ActiveRecord::Migration
  def up
  	rename_column :categories, :category_type, :category_type_code
  end

  def down
  end
end
