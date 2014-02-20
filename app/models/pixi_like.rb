class PixiLike < ActiveRecord::Base
  attr_accessible :pixi_id, :user_id

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id"

  validates :pixi_id, :presence => true
  validates :user_id, :presence => true, :uniqueness => { :scope => :pixi_id }
end
