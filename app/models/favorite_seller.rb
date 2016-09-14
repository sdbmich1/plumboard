class FavoriteSeller < ActiveRecord::Base
  attr_accessible :seller_id, :status, :user_id

  belongs_to :user
  belongs_to :seller, class_name: 'User'

  validates :user_id, :presence => true
  validates :seller_id, :presence => true, :uniqueness => { :scope => :user_id }
  validates :status, :presence => true

  def self.get_by_status val
    where(:status => val)
  end

  def self.save uid, sid, status
    fav = FavoriteSeller.find_by(user_id: uid, seller_id: sid)
    if fav.blank?
      fav = FavoriteSeller.create(user_id: uid, seller_id: sid, status: status)
    else
      fav.update_attribute(:status, status) unless fav.status == status
    end
    fav
  end
end
