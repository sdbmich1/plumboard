class AddIndexOnNameOnSites < ActiveRecord::Migration
  def up
    add_index :sites, :name
  end

  def down
    remove_index :sites, :name
  end
end
