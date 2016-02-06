class RenameActiveCardsCountToActiveCardAccountsCountOnUsers < ActiveRecord::Migration
  def up
    rename_column :users, :active_cards_count, :active_card_accounts_count
  end

  def down
    rename_column :users, :active_card_accounts_count, :active_cards_count
  end
end
