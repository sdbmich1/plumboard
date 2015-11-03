class ShipAddress < ActiveRecord::Base
  attr_accessible :recipient_email, :recipient_first_name, :recipient_last_name, :user_id

  belongs_to :user
  has_many :contacts, as: :contactable

  def recipient_name
    [recipient_first_name, recipient_last_name].join(" ")
  end
end
