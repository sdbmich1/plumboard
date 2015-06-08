class AddIndexOnStatusToUsers < ActiveRecord::Migration
  def change
    add_index :users, :status
  end
end
