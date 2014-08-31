class AddStatusToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :status, :string
    add_index :conversations, :status
  end
end
