class AddPromoTypeToPromoCode < ActiveRecord::Migration
  def change
    add_column :promo_codes, :promo_type, :string
    add_column :promo_codes, :site_id, :integer

    add_index :promo_codes, :site_id
  end
end
