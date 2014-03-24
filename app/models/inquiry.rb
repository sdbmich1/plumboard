class Inquiry < ActiveRecord::Base
  attr_accessible :comments, :email, :first_name, :code, :last_name, :user_id, :status
  before_create :set_flds

  belongs_to :user
  belongs_to :inquiry_type, foreign_key: 'code', primary_key: 'code'

  # name format validators
  name_regex = 	/^[A-Z]'?['-., a-zA-Z]+$/i
  email_regex = /[\w-]+@([\w-]+\.)+[\w-]+/i

  # validate added fields  				  
  validates :first_name,  :presence => true,
            :length   => { :maximum => 30 },
 	    :format => { :with => name_regex }  

  validates :last_name,  :presence => true,
            :length   => { :maximum => 30 },
 	    :format => { :with => name_regex }  

  validates :email, presence: true, :format => { :with => email_regex }  
  validates :comments, presence: true
  validates :code, presence: true

  default_scope order: 'inquiries.created_at DESC'

  # set fields upon creation
  def set_flds
    self.status = 'active' if self.status.blank?
  end
  
  # select active inquiries
  def self.active
    where(:status => 'active')
  end

  # get user name for inquiry
  def user_name
    first_name + ' ' + last_name rescue nil
  end

  # get contact_type for inquiry
  def contact_type
    inquiry_type.contact_type rescue nil
  end

  # get subject for inquiry
  def subject
    inquiry_type.subject rescue nil
  end

  # check category for inquiry
  def is_support?
    inquiry_type.contact_type == 'support' rescue nil
  end

  # find inquiries by status
  def self.get_by_status val
    where(:status => val).order('updated_at DESC')
  end

  # find inquiries by contact type
  def self.get_by_contact_type val
    active.select('inquiries.id, inquiries.user_id, inquiries.first_name, inquiries.last_name, inquiry_types.subject, inquiries.comments, 
      inquiries.status, inquiries.email, inquiries.created_at').joins(:inquiry_type).where('inquiry_types.contact_type = ?', val)
  end
end
