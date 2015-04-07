class PixiPostDetail < ActiveRecord::Base
  attr_accessible :pixi_id, :pixi_post_id

  belongs_to :pixi_post
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"

  validates_presence_of :pixi_id

  def title
    listing.title rescue nil
  end

  # set json string
  def as_json(options={})
    super(only: [:pixi_id], 
      methods: [:title])
  end
end
