class CreateOrgTypes < ActiveRecord::Migration
  def change
    create_table :org_types do |t|
      t.string :code
      t.string :status
      t.string :hide
      t.string :description

      t.timestamps
    end
    add_index :org_types, :code
  end
end
