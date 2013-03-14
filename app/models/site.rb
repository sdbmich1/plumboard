class Site < ActiveRecord::Base
  attr_accessible :email, :name, :org_type, :status, :institution_id, :pictures_attributes, :contacts_attributes

  has_many :site_users
  has_many :users, :through => :site_users

  has_many :listings, :dependent => :destroy
  has_many :site_listings, :dependent => :destroy

  has_many :temp_listings, :dependent => :destroy

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  has_many :contacts, :as => :contactable, :dependent => :destroy
  accepts_nested_attributes_for :contacts, :allow_destroy => true

  validates :name, :presence => true

  default_scope :order => "name ASC"
  
  def self.active
    where(:status => 'active')
  end
end
