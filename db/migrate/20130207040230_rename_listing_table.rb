class RenameListingTable < ActiveRecord::Migration
  def up
    rename_column :listings, :org_id, :site_id
  end

  def down
    rename_column :listings, :site_id, :org_id
  end
end
