class Category < ActiveRecord::Base
  attr_accessible :category_type, :name, :status

  has_many :listings

  default_scope :order => "name ASC"

  def self.active
    where(:status => 'active')
  end
end
