class PixiPost < ActiveRecord::Base
  attr_accessible :address, :alt_date, :alt_time, :city, :description, :pixan_id, :preferred_date, :preferred_time, :quantity, :state, 
    :user_id, :value, :zip, :status

  belongs_to :user

  validates :user_id, presence: true
  validates :preferred_date, presence: true
  validates :preferred_time, presence: true
  validates :value, presence: true
  validates :quantity, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :zip, presence: true
  validates :description, presence: true
end
