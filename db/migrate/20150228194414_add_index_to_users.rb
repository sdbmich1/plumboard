class AddIndexToUsers < ActiveRecord::Migration
  def change
    remove_index :users, :url
    add_index :users, :url, :unique => true
  end
end
