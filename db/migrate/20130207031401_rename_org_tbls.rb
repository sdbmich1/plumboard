class RenameOrgTbls < ActiveRecord::Migration
  def up
    rename_column :org_users, :org_id, :site_id
    rename_column :org_listings, :org_id, :site_id
    rename_table :org_listings, :site_listings
    rename_table :org_users, :site_users
  end

  def down
    rename_table :site_listings, :org_listings
    rename_table :site_users, :org_users
  end
end
