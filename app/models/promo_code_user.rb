class PromoCodeUser < ActiveRecord::Base
  attr_accessible :user_id, :promo_code_id, :status

  belongs_to :user
  belongs_to :promo_code

  validates :user_id, :presence => true
  validates :promo_code_id, :presence => true

  # find by status
  def self.get_by_status val
    where(:status => val)
  end

  # set status
  def self.set_status pid, uid, stype
    where("promo_code_id = ? AND user_id = ? AND status = ?", pid, uid, 'active').update_all(status: stype)
  end
end
