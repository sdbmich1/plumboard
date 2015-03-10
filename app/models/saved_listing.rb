class SavedListing < ActiveRecord::Base
  attr_accessible :pixi_id, :user_id, :status

  before_create :set_flds

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id", touch: true

  validates :pixi_id, :presence => true
  validates :user_id, :presence => true

  #return first_name
  def first_name
    return user.first_name rescue nil
  end

  # set fields upon creation
  def set_flds
    self.status = 'active' if self.status.blank?
  end

  # find listings by status
  def self.get_by_status val
    where(:status => val).order('updated_at DESC')
  end

  # find active by pixi
  def self.active_by_pixi pid
    where("pixi_id = ? AND status = 'active'", pid)
  end

  # update status
  def self.update_status pid, val
    active_by_pixi(pid).update_all(status: val) rescue nil
  end

  # update status by user
  def self.update_status_by_user uid, pid, val
    where("pixi_id = ? AND user_id = ?", pid, uid).first.update_attribute(:status, val) rescue nil
  end
end
