class Post < ActiveRecord::Base
  resourcify
  acts_as_readable :on => :created_at

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

  default_scope order: 'posts.created_at DESC'

  # load default content
  def self.load_new listing
    if listing
      new_post = listing.posts.build
      new_post.recipient_id, new_post.pixi_id = listing.seller_id, listing.pixi_id
      new_post.content = PIXI_POST
      new_post
    end
  end

  # short content
  def summary
    descr = content.length < 100 ? content.html_safe : content.html_safe[0..99] rescue nil
    Rinku.auto_link(descr) if descr
  end

  # add hyperlinks to content
  def full_content
    Rinku.auto_link(content.html_safe) rescue nil
  end

  # check if content length > 100
  def long_content?
    content.length > 100
  end

  # check if user is sender
  def sender? usr
    usr.id == user_id
  end

  # get recipient
  def self.get_unread usr
    where(:recipient_id=>usr).unread_by(usr) rescue nil
  end

  # get count of unread messages
  def self.unread_count usr
    get_unread(usr).count
  end
end
