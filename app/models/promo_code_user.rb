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

  def self.save uid, pid, status='active'
    pc = find_by(user_id: uid, promo_code_id: pid)
    if pc.blank?
      pc = create(user_id: uid, promo_code_id: pid, status: status)
    else
      pc.update_attribute(:status, status) unless pc.status == status
    end
    pc
  end

  def self.get_by_user uid, status='active'
    where("user_id = ? AND status = ?", uid, status)
  end
end
