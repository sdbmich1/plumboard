class AddStatusToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :status, :string
    add_index :posts, :status
  end
end
