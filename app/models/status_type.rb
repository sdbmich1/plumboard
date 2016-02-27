class StatusType < ActiveRecord::Base
  attr_accessible :code, :hide

  validates :code, :presence => true

  default_scope { order 'status_types.code ASC' }

  # return active types
  def self.active
    where(:code => 'active')
  end

  # return all unhidden types
  def self.unhidden
    where("hide <> 'yes' OR hide IS NULL")
  end

  # titleize code
  def code_title
    code.titleize rescue nil
  end
end
