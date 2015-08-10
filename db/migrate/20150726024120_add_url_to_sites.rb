class AddUrlToSites < ActiveRecord::Migration
  def change
    add_column :sites, :url, :string
    add_index :sites, :url
  end
end
