class Category < ActiveRecord::Base
  attr_accessible :category_type, :name, :status

  has_many :listings
  has_many :temp_listings

  validates :name, :presence => true
  validates :status, :presence => true
  validates :category_type, :presence => true

  default_scope :order => "name ASC"

  def self.active
    where(:status => 'active')
  end
end
