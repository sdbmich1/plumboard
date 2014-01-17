class ChangeCardAccountNumber < ActiveRecord::Migration
  def up
    rename_column :card_accounts, :card_number, :card_no
  end

  def down
    rename_column :card_accounts, :card_no, :card_number
  end
end
