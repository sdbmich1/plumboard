class Conversation < ActiveRecord::Base
  attr_accessible :pixi_id, :recipient_id, :user_id, :status, :recipient_status, :posts_attributes, :quantity
  attr_accessor :quantity

  before_create :activate
  after_commit :process_want_requests, :on => :create
  after_commit :process_pixi_requests, :on => :update
  has_many :posts, :inverse_of => :conversation
  accepts_nested_attributes_for :posts, :allow_destroy => true

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :recipient, class_name: 'User', foreign_key: :recipient_id

  # user id is person who starts the conversation and sends first post
  validates_presence_of :user_id, :pixi_id, :recipient_id

  # set active status
  def activate
    if self.status != 'removed'
      self.status = 'active'
    end
    if self.recipient_status != 'removed'
      self.recipient_status = 'active'
    end
    self
  end

  # check if user is sender
  def sender? usr
    usr.id == user_id
  end

  # checks if conv is a replied to message
  def replied_conv? usr
    if posts.count > 1 && posts.last.user_id != usr.id
      posts.each do |post|
        return true if post.user_id == usr.id
      end
    end
    false
  end

  # returns the other user that is a part of this conversation
  def other_user usr
    usr.id == user_id ? recipient : user
  end
  
  # checks whether invoice for user is due
  def due_invoice? usr
    posts.detect { |post| post.due_invoice? usr }
  end

  # checks whether user can bill
  def can_bill? usr
    posts.detect { |post| post.can_bill? usr }
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
    posts.each do |post| 
      if post.unread?(usr) && post.recipient_id == usr.id
        return true
      end
    end
    return false
  end

  # select active conversations
  def self.active
    where("status = 'active' OR recipient_status = 'active'")
  end

  # get all conversations for user where status or recipient status is active
  def self.get_conversations usr
    inc_list.active.where("recipient_id = ? OR user_id = ?", usr, usr.id)
  end

  # check if user has a message in the conversation
  def self.usr_msg? convo, usr
    (usr.id == convo.user_id && convo.status == 'active') || (usr.id == convo.recipient_id && convo.recipient_status == 'active')
  end

  # count number of active posts in a conversation for a specific user
  def active_post_count usr
    posts.active_status(usr).size rescue 0
  end

  # get conversations where user has sent/received at least one message in conversation and conversation is active
  # for the user
  def self.get_specific_conversations usr, c_type 
    conv_ids = Array.new
    convos = Conversation.get_conversations(usr)
    convos.find_each do |convo|
      convo.posts.find_each do |post|
        if (c_type == "received" && post.recipient_id == usr.id && post.recipient_status == 'active') ||
           (c_type == "sent" && post.user_id == usr.id && post.status == 'active')
          conv_ids << convo.id if usr_msg?(convo, usr); break
        end
      end
    end
    # return convos.where(["id in (?)", conv_ids]).sort_by {|x| x.posts.first.created_at }.reverse 
    return convos.where(["id in (?)", conv_ids]).sort_by {|x| x.updated_at }.reverse 
  end

  # set list of included assns for eager loading
  def self.inc_list
    includes(:posts, :recipient => :pictures, :user => :pictures, :listing => {:invoices => [:invoice_details, :buyer, :seller]})
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
    if user.id == conv.user_id
      update_status(conv, user, 'status')
    elsif user.id == conv.recipient_id 
      update_status(conv, user, 'recipient_status')
    end
    false
  end

  # update appropriate status fld
  def self.update_status conv, user, fld
    if conv.update_attribute(fld.to_sym, 'removed')
      conv.remove_posts(user)
      true
    else
      false
    end
  end

  # sets all posts in a convo to 'removed'
  def remove_posts usr
    posts.each do |post|
      if usr.id == post.user_id
        post.status = 'removed'
      elsif usr.id == post.recipient_id
        post.recipient_status = 'removed'
      end
      post.save
    end
  end

  # return create date
  def create_dt
    dt = posts.last.created_at rescue Date.today 
    new_dt = listing.display_date updated_at, false rescue dt
  end

  # mark all posts in a conversation
  def mark_all_posts usr
    return false if usr.blank?
    posts.each do |post|
      post.mark_as_read! for: usr if post
    end
  end

  # add pixi requests
  def process_pixi_requests
    add_want_request
  end

  # add pixi requests
  def process_want_requests
    add_want_request
  end

  # process request
  def add_want_request
    if posts.where('msg_type= ? AND status= ?', 'want', 'active').first
      user.pixi_wants.create(pixi_id: self.pixi_id, quantity: self.quantity, status: 'active')
    end
  end
end
