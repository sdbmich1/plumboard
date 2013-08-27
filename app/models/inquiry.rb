class Inquiry < ActiveRecord::Base
  attr_accessible :comments, :email, :first_name, :inquiry_type, :last_name, :user_id
end
