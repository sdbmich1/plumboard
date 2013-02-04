class ListingCategory < ActiveRecord::Base
  attr_accessible :category_id, :listing_id

  belongs_to :listing
  belongs_to :category

  validates :category_id, :presence => true
  validates :listing_id, :presence => true, :uniqueness => { :scope => :category_id }
end
