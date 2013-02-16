class SiteUser < ActiveRecord::Base
  attr_accessible :site_id, :user_id

  belongs_to :site
  belongs_to :user

  validates :site_id, :presence => true
  validates :user_id, :presence => true, :uniqueness => { :scope => :site_id }
end
