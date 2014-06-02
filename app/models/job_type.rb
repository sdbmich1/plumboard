class JobType < ActiveRecord::Base
  attr_accessible :code, :job_name, :status

  validates :job_name, :presence => true
  validates :status, :presence => true
  validates :code, :presence => true

  has_many :listings, foreign_key: 'job_type_code', primary_key: 'code'
  has_many :temp_listings, foreign_key: 'job_type_code', primary_key: 'code'
  has_many :old_listings, foreign_key: 'job_type_code', primary_key: 'code'

  default_scope :order => "job_name ASC"

  # return active categories
  def self.active
    where(:status => 'active')
  end
end
