class AddCategoryTypeToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :pixi_type, :string
  end
end
