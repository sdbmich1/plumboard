class ConditionType < ActiveRecord::Base
  attr_accessible :code, :hide, :status

  validates :code, :presence => true
  validates :hide, :presence => true
  validates :status, :presence => true

  # default_scope :order => "Condition Type ASC"#what am i doing here?

  # return active types
  def self.active
    where(:status => 'active')
  end

    # return all unhidden types
  def self.unhidden
    where(:hide => 'no')
  end
end
