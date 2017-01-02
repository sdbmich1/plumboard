class PixiWant < ActiveRecord::Base
  attr_accessible :pixi_id, :user_id, :quantity, :status, :fulfillment_type_code

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id", touch: true

  validates :pixi_id, :presence => true
  validates :user_id, :presence => true

  # find by status
  def self.get_by_status val
    where(:status => val)
  end

  # get pixi want user name
  def user_name
    user.name rescue nil
  end

  # set want status
  def self.set_status pid, uid, stype
    where("pixi_id = ? AND user_id = ? AND status = ?", pid, uid, 'active').update_all(status: stype)
  end

  def self.save uid, pid, status, qty	
    want = find_by(user_id: uid, pixi_id: pid, status: 'active')
    if want.blank?
      want = create(user_id: uid, pixi_id: pid, status: status, quantity: qty)
    else
      want.update_attribute(:quantity, qty) unless want.quantity == qty
    end
    want
  end
end
