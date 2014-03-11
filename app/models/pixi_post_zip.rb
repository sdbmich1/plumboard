class PixiPostZip < ActiveRecord::Base
  attr_accessible :city, :state, :status, :zip

  validates :city, :presence => true
  validates :status, :presence => true
  validates :state, :presence => true
  validates :zip, :presence => true

  # return active categories
  def self.active
    where(:status => 'active')
  end
end
