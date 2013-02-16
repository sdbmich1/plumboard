class AddInstIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :institution_id, :integer
    add_index :organizations, :institution_id
  end
end
