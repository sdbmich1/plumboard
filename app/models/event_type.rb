class EventType < ActiveRecord::Base
  attr_accessible :code, :description, :hide, :status
  
  validates_presence_of :description, :code, :hide, :status
  
  has_many :listings, foreign_key: 'event_type_code', primary_key: 'code'
  has_many :temp_listings, foreign_key: 'event_type_code', primary_key: 'code'

  default_scope { order 'event_types.description ASC' }
  
  # return active types
  def self.active
    where(:status => 'active')
  end

  # titleize descr
  def nice_descr
    description.titleize rescue nil
  end
end
