class AddTidToListing < ActiveRecord::Migration
  def change
    add_column :listings, :transaction_id, :integer
    add_index :listings, :transaction_id
  end
end
