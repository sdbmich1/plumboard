class RenameOrgTable < ActiveRecord::Migration
  def up
    rename_table :organizations, :sites
  end

  def down
    rename_table :sites, :organizations
  end
end
