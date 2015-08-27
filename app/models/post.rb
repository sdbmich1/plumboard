class Post < ActiveRecord::Base
  resourcify
  acts_as_readable :on => :created_at

  attr_accessible :content, :user_id, :pixi_id, :recipient_id, :msg_type, :conversation_id, :status, :recipient_status

  PIXI_POST = PIXI_KEYS['pixi']['pixi_post']
  MAX_SIZE = 100

  before_create :activate
  after_commit :process_pixi_requests, :on => :create

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :recipient, class_name: 'User', foreign_key: :recipient_id
  belongs_to :conversation, :inverse_of => :posts, touch: true, counter_cache: true

  validates_presence_of :conversation, :content, :user_id, :pixi_id, :recipient_id

  # set active status
  def activate
    PostProcessor.new(self).activate
  end

  # select active posts
  def self.active
    include_list.where("status = 'active' OR recipient_status = 'active'")
  end

  # select active posts based on status type
  def self.active_status usr
    where("(status = 'active' AND user_id = ?) OR (recipient_id = ? AND recipient_status = 'active')", usr.id, usr.id)
  end

  # eager load assns
  def self.include_list
    includes(:user, :listing, :recipient, :conversation)
  end

  # load default content
  def self.load_new listing
    listing.posts.build recipient_id: listing.seller_id if listing
  end

  # short content
  def summary num=MAX_SIZE, showTailFlg=false
    PostProcessor.new(self).summary num, showTailFlg
  end

  # add hyperlinks to content
  def full_content
    PostProcessor.new(self).full_content
  end

  # check if content length > MAX_SIZE
  def long_content? num=MAX_SIZE
    content.length > num
  end

  # check if user is sender
  def sender? usr
    usr.id == user_id
  end

  # get sender name
  def sender_name
    user.name if user
  end

  # get recipient name
  def recipient_name
    recipient.name if recipient
  end

  # get sender email
  def sender_email
    user.email if user
  end

  # get recipient email
  def recipient_email
    recipient.email if recipient
  end

  # get pixi title
  def pixi_title
    listing.title if listing
  end

  # set list of included assns for eager loading
  def self.inc_list
    active.includes(:listing => [:pictures], :user => [:pictures], :recipient => [:pictures])
  end

  # get sent posts for user
  def self.get_sent_posts usr
    inc_list.where("user_id = ? AND status = ?", usr, 'active')
  end

  # get posts for recipient
  def self.get_posts usr
    inc_list.where("recipient_id = ? AND recipient_status = ?", usr, 'active')
  end

  # get unread posts for recipient
  def self.get_unread usr
    get_posts(usr).unread_by(usr) rescue nil
  end

  # get count of unread messages
  def self.unread_count usr
    get_unread(usr).count rescue 0
  end

  # add post for invoice creation or payment
  def self.add_post inv, listing, sender, recipient, msg, msgType=''
    PostProcessor.new(self).add_post inv, listing, sender, recipient, msg, msgType
  end

  # send invoice post
  def self.send_invoice inv, listing
    PostProcessor.new(self).send_invoice inv, listing
  end

  # pay invoice post
  def self.pay_invoice model
    PostProcessor.new(self).pay_invoice model
  end

  # check if invoice is due
  def due_invoice? usr
    check_invoice usr, false, 'buyer_name' 
  end

  # checks whether user can bill
  def can_bill? usr
    check_invoice(usr, true, 'seller_name')
  end

  # check invoice status for buyer or seller
  def check_invoice usr, flg, fld
    PostProcessor.new(self).check_invoice usr, flg, fld
  end

  # check if invoice msg 
  def inv_msg?
    msg_type == 'inv'
  end

  # check if want msg 
  def want_msg?
    msg_type == 'want'
  end

  # check if ask msg 
  def ask_msg?
    msg_type == 'ask'
  end

  # check if system msg 
  def system_msg?
    %w(approve deny system repost).detect {|x| msg_type == x}
  end

  # set json string
  def as_json(options={})
    super(except: [:updated_at], methods: [:pixi_title, :recipient_name, :sender_name], 
      include: {recipient: { only: [:first_name], methods: [:photo] }, user: { only: [:first_name], methods: [:photo] }})
  end

  # map messages to conversations if needed
  def self.map_posts_to_conversations
    PostProcessor.new(self).map_posts_to_conversations
  end

  # removes given posts for a specific user
  def remove_post user 
    PostProcessor.new(self).remove_post user
  end

  # return create date
  def create_dt
    new_dt = listing.display_date created_at, false rescue created_at
  end

  # add pixi requests
  def process_pixi_requests
    user.pixi_asks.create(pixi_id: self.pixi_id) if msg_type == 'ask'
  end
end
