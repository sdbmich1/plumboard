require 'rails_rinku'
class Faq < ActiveRecord::Base
  attr_accessible :description, :question_type, :status, :subject

  before_create :set_flds

  validates :description, presence: true
  validates :subject, presence: true
  validates :question_type, presence: true

  # set fields upon creation
  def set_flds
    self.status = 'active' if self.status.blank?
  end
  
  # select active inquiries
  def self.active
    where(:status => 'active')
  end

  # add hyperlinks to description
  def summary
    Rinku.auto_link(description.html_safe) rescue nil
  end
end
