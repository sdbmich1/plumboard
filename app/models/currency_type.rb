class CurrencyType < ActiveRecord::Base
  attr_accessible :code, :description, :hide, :status

  validates_presence_of :description, :code, :hide, :status

  default_scope :order => "description ASC"

  # return active types
  def self.active
    where(:status => 'active')
  end

  def self.inactive
  	where(:status => 'inactive')
  end

  # return all unhidden types
  def self.unhidden
    active.where(:hide => 'no')
  end

  def self.hidden
    active.where(:hide => 'yes')
  end

  # titleize descr
  def nice_descr
    description.titleize rescue nil
  end
end
