class Conversation < ActiveRecord::Base
  attr_accessible :pixi_id, :recipient_id, :user_id, :status, :recipient_status,
    :posts_attributes, :quantity, :fulfillment_type_code
  attr_accessor :quantity, :fulfillment_type_code

  before_create :activate
  after_commit :process_want_requests, :on => :create
  after_commit :process_pixi_requests, :on => :update
  has_many :posts, :inverse_of => :conversation
  accepts_nested_attributes_for :posts, :allow_destroy => true
  has_many :active_posts, -> { where status: 'active' }, class_name: 'Post'

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :recipient, class_name: 'User', foreign_key: :recipient_id

  # user id is person who starts the conversation and sends first post
  validates_presence_of :user_id, :pixi_id, :recipient_id

  # set active status
  def activate
    ConversationProcessor.new(self).activate
  end

  # check if user is sender
  def sender? usr
    usr.id == user_id
  end

  # checks if conv is a replied to message
  def replied_conv? usr
    ConversationProcessor.new(self).replied_conv? usr
  end

  # returns the other user that is a part of this conversation
  def other_user usr
    usr.id == user_id ? recipient : user
  end
  
  # checks whether invoice for user is due
  def due_invoice? usr
    !posts.detect { |post| post.due_invoice? usr }.nil?
  end

  # checks whether invoice for sender is due
  def sender_due_invoice?
    !posts.detect { |post| post.due_invoice? user }.nil?
  end

  # checks whether invoice for recipient is due
  def recipient_due_invoice?
    !posts.detect { |post| post.due_invoice? recipient }.nil?
  end

  # checks whether user can bill
  def can_bill? usr
    !posts.detect { |post| post.can_bill? usr }.nil?
  end

  # checks whether sender can bill
  def sender_can_bill?
    !posts.detect { |post| post.can_bill? user }.nil?
  end

  # checks whether recipient can bill
  def recipient_can_bill?
    !posts.detect { |post| post.can_bill? recipient }.nil?
  end

  # pixi title
  def pixi_title
    listing.title rescue nil
  end

  # check for system message
  def system_msg?
    posts.first.system_msg? rescue nil
  end

  # set content display
  def content_msg val=35
    posts.last.content.length > val ? posts.last.summary(val) + '...' : posts.last.summary(val) rescue nil
  end

  # returns whether conversation has any associated unread posts
  def any_unread? usr
    ConversationProcessor.new(self).any_unread? usr
  end

  # select active conversations
  def self.active
    where("status = 'active' OR recipient_status = 'active'")
  end

  # get all conversations for user where status or recipient status is active
  def self.get_conversations usr
    inc_list.active.where("recipient_id = ? OR user_id = ?", usr, usr.id)
  end

  # count number of active posts in a conversation for a specific user
  def active_post_count usr
    posts.active_status(usr).size rescue 0
  end

  # get conversations where user has sent/received at least one message in conversation and conversation is active
  # for the user
  def self.get_specific_conversations usr, c_type 
    ConversationProcessor.new(self).get_specific_conversations usr, c_type 
  end

  # set list of included assns for eager loading
  def self.inc_list
    includes(:posts => [:listing], :recipient => :pictures, :user => :pictures, :listing => [:site, :user, {:invoices => [:invoice_details, :buyer, :seller]}])
  end

  # set list of included assns for eager loading
  def self.inc_show_list
    includes(:posts => [:listing, {:user => :pictures}])
  end

  # get the conversation
  def self.get_conv pid, recvID, sendID
    where("pixi_id = ? AND recipient_id = ? AND user_id = ? AND status = ?", pid, recvID, sendID, 'active').first rescue nil
  end

  # sets convo status to 'removed'
  def self.remove_conv conv, user 
    ConversationProcessor.new(self).remove_conv conv, user 
  end

  # sets all posts in a convo to 'removed'
  def remove_posts usr
    ConversationProcessor.new(self).remove_posts usr
  end

  # return create date
  def create_dt
    dt = posts.last.created_at rescue Date.today 
    new_dt = listing.display_date updated_at, false rescue dt
  end

  # mark all posts in a conversation
  def mark_all_posts usr
    ConversationProcessor.new(self).mark_all_posts usr
  end

  # add pixi requests
  def process_pixi_requests
    ConversationProcessor.new(self).add_want_request
  end

  # add pixi requests
  def process_want_requests
    ConversationProcessor.new(self).add_want_request
  end

  # get sender name
  def sender_name
    user.name if user
  end

  # get recipient name
  def recipient_name
    recipient.name if recipient
  end

  def invoice_id
    inv = Invoice.get_by_status_and_pixi('unpaid', user.id, pixi_id).first
    inv.id if inv
  end

  # get posts
  def get_posts user
    posts.active_status(user).reorder('created_at ASC')
  end

  # set json string
  def as_json(options={})
    result = super(except: [:updated_at], methods: [:pixi_title, :recipient_name, :sender_name, :create_dt,
                                 :sender_can_bill?, :recipient_can_bill?, :sender_due_invoice?, :recipient_due_invoice?, :invoice_id], 
              include: {recipient: { only: [:first_name], methods: [:photo] }, user: { only: [:first_name], methods: [:photo] },
                listing: { only: [], methods: [:photo_url] } })
    result['get_posts'] = get_posts(options[:user] || user)
    result
  end
end
