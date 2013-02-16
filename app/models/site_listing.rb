class SiteListing < ActiveRecord::Base
  attr_accessible :listing_id, :site_id

  belongs_to :site
  belongs_to :listing

  validates :site_id, :presence => true
  validates :listing_id, :presence => true, :uniqueness => { :scope => :site_id }

end
