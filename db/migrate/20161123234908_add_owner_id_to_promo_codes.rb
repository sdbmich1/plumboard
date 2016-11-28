class AddOwnerIdToPromoCodes < ActiveRecord::Migration
  def change
    add_column :promo_codes, :owner_id, :integer
    add_index :promo_codes, :owner_id
  end
end
