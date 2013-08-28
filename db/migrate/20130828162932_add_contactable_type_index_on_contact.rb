class AddContactableTypeIndexOnContact < ActiveRecord::Migration
  def up
    add_index :contacts, :contactable_type
  end

  def down
  end
end
