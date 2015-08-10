class RenameOrgTypeToSiteTypeCodeOnSites < ActiveRecord::Migration
  def up
    rename_column :sites, :org_type, :site_type_code
  end

  def down
    rename_column :sites, :site_type_code, :org_type
  end
end
