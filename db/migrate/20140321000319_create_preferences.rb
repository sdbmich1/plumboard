class CreatePreferences < ActiveRecord::Migration
  def change
    create_table :preferences do |t|
      t.integer :user_id
      t.string :zip
      t.string :email_msg_flg
      t.string :mobile_msg_flg

      t.timestamps
    end
    add_index :preferences, [:user_id, :zip]
  end
end
