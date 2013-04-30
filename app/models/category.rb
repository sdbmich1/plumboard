class Category < ActiveRecord::Base
  attr_accessible :category_type, :name, :status, :pixi_type

  has_many :listings
  has_many :temp_listings

  validates :name, :presence => true
  validates :status, :presence => true
  validates :category_type, :presence => true

  default_scope :order => "name ASC"

  def self.active
    where(:status => 'active')
  end

  def premium?
    pixi_type == 'premium'  
  end
end
