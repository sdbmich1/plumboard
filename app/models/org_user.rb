class OrgUser < ActiveRecord::Base
  attr_accessible :org_id, :user_id

  belongs_to :organization, :foreign_key => :org_id
  belongs_to :user

  validates :org_id, :presence => true
  validates :user_id, :presence => true, :uniqueness => { :scope => :org_id }
end
