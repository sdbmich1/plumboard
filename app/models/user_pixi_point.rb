class UserPixiPoint < ActiveRecord::Base
  attr_accessible :code, :user_id

  belongs_to :user
  belongs_to :pixi_point, foreign_key: :code, primary_key: :code

  validates :code, presence: true
  validates :user_id, presence: true
end
