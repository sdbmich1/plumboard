class AddConversationIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :conversation_id, :integer
    add_index :posts, :conversation_id
  end
end
