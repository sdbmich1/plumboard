class CategoryType < ActiveRecord::Base
  attr_accessible :code, :hide, :status

  validates :code, :presence => true
  validates :status, :presence => true
  validates :hide, :presence => true

  has_many :categories, primary_key: 'code', foreign_key: 'category_type_code'

  default_scope { order 'category_types.code ASC' }

  # return active types
  def self.active 
    where(:status => 'active')
  end
end
