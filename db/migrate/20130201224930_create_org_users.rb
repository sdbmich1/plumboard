class CreateOrgUsers < ActiveRecord::Migration
  def change
    create_table :org_users do |t|
      t.integer :org_id
      t.integer :user_id

      t.timestamps
    end

    add_index :org_users, [:org_id, :user_id], :unique => true
  end
end
