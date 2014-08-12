class CategoryType < ActiveRecord::Base
  attr_accessible :code, :hide, :status

  validates :code, :presence => true
  validates :status, :presence => true
  validates :hide, :presence => true

  has_many :categories, primary_key: 'code', foreign_key: 'category_type_code'

  # return active types
  def self.active 
  	where(:status => 'active')
  end

  def proper
    return self.code
  end
end
