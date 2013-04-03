class Post < ActiveRecord::Base
  resourcify
  attr_accessible :content, :listing_id, :user_id, :pixi_id, :recipient_id

  PIXI_POST = PIXI_KEYS['pixi']['pixi_post']

  belongs_to :user
  belongs_to :listing
  belongs_to :recipient, class_name: 'User', foreign_key: :recipient_id

  validates :content, :presence => true 
  validates :listing_id, :presence => true
  validates :user_id, :presence => true
  validates :pixi_id, :presence => true
  validates :recipient_id, :presence => true

  # load default content
  def self.load_new listing
    if listing
      new_post = listing.posts.build
      new_post.recipient_id, new_post.pixi_id = listing.seller_id, listing.pixi_id
      new_post.content = PIXI_POST
      new_post
    end
  end
end
