class Category < ActiveRecord::Base
  attr_accessible :category_type, :name, :status

  has_many :listing_categories

  def self.active
    where(:status => 'active')
  end
end
