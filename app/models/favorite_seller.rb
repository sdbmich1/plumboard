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
end
