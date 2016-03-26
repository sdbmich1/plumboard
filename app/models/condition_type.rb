class ConditionType < ActiveRecord::Base
  attr_accessible :code, :hide, :status, :description

  validates_presence_of :description, :code, :hide, :status

  default_scope { order "description ASC" }

  # return active types
  def self.active
    where(:status => 'active')
  end

  # return all unhidden types
  def self.unhidden
    active.where(:hide => 'no')
  end

  # titleize descr
  def nice_descr
    description.titleize rescue nil
  end
end
