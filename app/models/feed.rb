class Feed < ActiveRecord::Base
  attr_accessible :description, :site_id, :site_name, :status, :url

  validates :url, :presence => :true
end
