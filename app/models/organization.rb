class Organization < ActiveRecord::Base
  attr_accessible :email, :name, :org_type, :status

  has_many :org_listings, :foreign_key => :org_id, :dependent => :destroy
  has_many :org_users, :foreign_key => :org_id
  has_many :users, :through => :org_users

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  validates :name, :presence => true
  
  def self.active
    where(:status => 'active')
  end
end
