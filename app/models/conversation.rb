class Conversation < ActiveRecord::Base
  attr_accessible :pixi_id, :recipient_id, :user_id

  has_many :posts

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :recipient, class_name: 'User', foreign_key: :recipient_id
  belongs_to :invoice, foreign_key: 'pixi_id', primary_key: 'pixi_id'

  # user id is person who starts the conversation and sends first post
  validates :user_id, :presence => true
  validates :pixi_id, :presence => true
  validates :recipient_id, :presence => true
end
