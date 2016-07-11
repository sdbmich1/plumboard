class Device < ActiveRecord::Base
  attr_accessible :user_id, :token, :platform, :status, :vibrate

  belongs_to :user

  validates :token, uniqueness: { scope: :user_id }, presence: true
  validates :user_id, presence: true
end
