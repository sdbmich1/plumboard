class AddRecipientStatusToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :recipient_status, :string
    add_index :posts, :recipient_status
  end
end
