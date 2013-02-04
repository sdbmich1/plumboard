class OrgListing < ActiveRecord::Base
  attr_accessible :listing_id, :org_id

  belongs_to :organization, :foreign_key => :org_id
  belongs_to :listing

  validates :org_id, :presence => true
  validates :listing_id, :presence => true, :uniqueness => { :scope => :org_id }

end
