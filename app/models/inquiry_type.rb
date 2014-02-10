class InquiryType < ActiveRecord::Base
  attr_accessible :code, :subject, :status, :contact_type

  validates :subject, :presence => true
  validates :status, :presence => true
  validates :code, :presence => true
  validates :contact_type, :presence => true

  has_many :inquiries, foreign_key: 'code', primary_key: 'code'

  default_scope :order => "subject ASC"

  # return active types
  def self.active
    where(:status => 'active')
  end

  # return support types
  def self.support
    active.where(:contact_type => 'support')
  end

  # return general inquiry types
  def self.general
    active.where(:contact_type => 'inquiry')
  end
end
