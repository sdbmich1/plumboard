class AddAliasNameToListing < ActiveRecord::Migration
  def change
    add_column :listings, :alias_name, :string
  end
end
