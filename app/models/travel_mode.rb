class TravelMode < ActiveRecord::Base
  attr_accessible :description, :hide, :status, :mode, :travel_type

  validates_presence_of :mode, :status, :travel_type, :description

  def self.active
    where(:status => 'active')
  end

  def self.unhidden
    active.where(:hide => 'no')
  end

  def descr_title
    description.upcase if description
  end

  def details
    'Travel Mode: ' + description if description
  end    
end
