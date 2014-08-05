class EventType < ActiveRecord::Base
  attr_accessible :code, :description, :hide, :status
  
  validates :description, :presence => true
  validates :status, :presence => true
  validates :code, :presence => true
  validates :hide, :presence => true
  
  
  # return active types
  def self.active
    where(:status => 'active')
  end
end
