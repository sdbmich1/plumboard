class AddHideToUserTypes < ActiveRecord::Migration
  def change
    add_column :user_types, :hide, :string
  end
end
