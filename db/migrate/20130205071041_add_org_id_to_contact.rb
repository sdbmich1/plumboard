class AddOrgIdToContact < ActiveRecord::Migration
  def change
    drop_table :contacts
    create_table :contacts do |t|
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.string :home_phone
      t.string :work_phone
      t.string :mobile_phone
      t.string :website
      t.references :contactable, :polymorphic => true

      t.timestamps
    end
    add_index :contacts, :contactable_id
  end
end
