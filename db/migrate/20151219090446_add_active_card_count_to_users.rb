class AddActiveCardCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :active_cards_count, :integer
  end
end
