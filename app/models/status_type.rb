class StatusType < ActiveRecord::Base
  attr_accessible :code, :hide

  validates :code, :presence => true

  # return active types
  def self.active
    where(:code => 'active')
  end

  # return all unhidden types
  def self.unhidden
  	where("hide <> 'yes'")
  end
end
