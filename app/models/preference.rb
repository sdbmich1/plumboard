class Preference < ActiveRecord::Base
  attr_accessible :email_msg_flg, :mobile_msg_flg, :user_id, :zip

  belongs_to :user

  validates :zip, allow_blank: true, length: {is: 5}
end
