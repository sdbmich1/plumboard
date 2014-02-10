class JobType < ActiveRecord::Base
  attr_accessible :code, :job_name, :status

  validates :job_name, :presence => true
  validates :status, :presence => true
  validates :code, :presence => true

  default_scope :order => "job_name ASC"

  # return active categories
  def self.active
    where(:status => 'active')
  end
end
