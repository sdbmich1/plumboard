class AddLatIndexOnContacts < ActiveRecord::Migration
  def up
    add_index :contacts, :lat
  end

  def down
    remove_index :contacts, :lat
  end
end
