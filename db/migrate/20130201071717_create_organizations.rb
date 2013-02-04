class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :org_type
      t.string :status
      t.string :email

      t.timestamps
    end
  end
end
