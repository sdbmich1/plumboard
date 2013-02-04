class Interest < ActiveRecord::Base
  attr_accessible :name, :status

  has_many :user_interests
  has_many :users, :through => :user_interests

  validates :name, :presence => true

  def self.active
    where(:status=>'active')
  end
end
