class CreateShipAddresses < ActiveRecord::Migration
  def change
    create_table :ship_addresses do |t|
      t.integer :user_id
      t.string :recipient_first_name
      t.string :recipient_last_name
      t.string :recipient_email

      t.timestamps
    end
    add_index :ship_addresses, :user_id
  end
end
