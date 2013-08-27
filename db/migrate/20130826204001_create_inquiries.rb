class CreateInquiries < ActiveRecord::Migration
  def change
    create_table :inquiries do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.text :comments
      t.string :inquiry_type
      t.string :email

      t.timestamps
    end

    add_index :inquiries, :user_id
    add_index :inquiries, :email
  end
end
