class AddMsgTypeToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :msg_type, :string
    add_index :posts, :msg_type
  end
end
