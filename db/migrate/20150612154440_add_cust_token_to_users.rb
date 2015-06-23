class AddCustTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cust_token, :string
  end
end
