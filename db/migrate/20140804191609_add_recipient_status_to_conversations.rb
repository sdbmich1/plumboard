class AddRecipientStatusToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :recipient_status, :string
    add_index :conversations, :recipient_status
  end
end
