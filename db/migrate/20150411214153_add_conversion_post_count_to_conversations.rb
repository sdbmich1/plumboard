class AddConversionPostCountToConversations < ActiveRecord::Migration
  def change
    add_column :conversations, :posts_count, :integer
  end
end
