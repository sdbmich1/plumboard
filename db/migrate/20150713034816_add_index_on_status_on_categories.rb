class AddIndexOnStatusOnCategories < ActiveRecord::Migration
  def up
    add_index :categories, :status
    add_index :status_types, :hide
  end

  def down
    remove_index :categories, :status
    remove_index :status_types, :hide
  end
end
