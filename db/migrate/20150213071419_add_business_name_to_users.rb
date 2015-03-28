class AddBusinessNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :business_name, :string
    add_column :users, :ref_id, :integer
    add_column :users, :url, :string
    add_index :users, :business_name
    add_index :users, :ref_id
    add_index :users, :url
  end
end
