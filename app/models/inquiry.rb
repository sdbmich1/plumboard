class Inquiry < ActiveRecord::Base
  attr_accessible :comments, :email, :first_name, :inquiry_type, :last_name, :user_id, :status

  belongs_to :user

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
  validates :inquiry_type, presence: true

  default_scope order: 'inquiries.created_at DESC'
  
  # select active inquiries
  def self.active
    where(:status => 'active')
  end
end
