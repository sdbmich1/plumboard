# Make ReadMark compatible with Rails 4 and 'protected_attributes' gem
# (see line 3 of https://docs.omniref.com/ruby/gems/unread/0.3.0/files/lib/unread/read_mark.rb)
class ReadMark < ActiveRecord::Base
  attr_accessible :readable_id, :user_id, :readable_type, :timestamp
end
