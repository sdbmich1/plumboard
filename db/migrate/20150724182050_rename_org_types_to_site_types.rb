class RenameOrgTypesToSiteTypes < ActiveRecord::Migration
  def up                        
    rename_table :org_types, :site_types
  end

  def down
    rename_table :site_types, :org_types
  end
end
