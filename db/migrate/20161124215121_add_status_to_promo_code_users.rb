class AddStatusToPromoCodeUsers < ActiveRecord::Migration
  def change
    add_column :promo_code_users, :status, :string
  end
end
