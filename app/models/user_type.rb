class UserType < ActiveRecord::Base
  attr_accessible :code, :description, :status, :hide

  validates :description, :presence => true
  validates :status, :presence => true
  validates :code, :presence => true

  has_many :users, foreign_key: 'user_type_code', primary_key: 'code'

  default_scope :order => "description ASC"

  # return active types
  def self.active
    where(status: 'active')
  end

  # return all unhidden types
  def self.unhidden
    where(hide: 'no')
  end
end
