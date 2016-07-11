class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :user_id
      t.integer :device_id
      t.string :message_type_code
      t.string :content
      t.string :priority
      t.text :reg_id
      t.string :collapse_key

      t.timestamps null: false
    end
  end
end
