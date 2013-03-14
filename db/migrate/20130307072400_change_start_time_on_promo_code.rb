class ChangeStartTimeOnPromoCode < ActiveRecord::Migration
  def up
    change_column :promo_codes, :start_time, :datetime
    change_column :promo_codes, :end_time, :datetime
  end

  def down
    change_column :promo_codes, :start_time, :time
    change_column :promo_codes, :end_time, :time
  end
end
