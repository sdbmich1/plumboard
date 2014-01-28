class Rating < ActiveRecord::Base
  attr_accessible :comments, :seller_id, :user_id, :value, :pixi_id

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :seller, class_name: 'User', foreign_key: :seller_id

  validates :user_id, :presence => true
  validates :pixi_id, :presence => true
  validates :seller_id, :presence => true
  validates :value, :presence => true
end
