class AddDescriptionToBankAccount < ActiveRecord::Migration
  def change
    add_column :bank_accounts, :description, :string
  end
end
