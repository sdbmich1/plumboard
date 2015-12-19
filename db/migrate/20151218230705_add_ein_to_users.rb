class AddEinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ein, :integer
    add_column :users, :ssn_last4, :integer
  end
end
