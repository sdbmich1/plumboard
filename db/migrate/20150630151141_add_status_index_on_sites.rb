class AddStatusIndexOnSites < ActiveRecord::Migration
  def up
    add_index :sites, [:status, :org_type]
  end

  def down
    remove_index :sites, :column => [:status, :org_type]
  end
end
