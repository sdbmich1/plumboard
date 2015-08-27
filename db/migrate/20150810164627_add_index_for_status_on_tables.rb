class AddIndexForStatusOnTables < ActiveRecord::Migration
  def up
    add_index :sites, :status
    add_index :favorite_sellers, :status
  end

  def down
    remove_index :sites, :status
    remove_index :favorite_sellers, :status
  end
end
