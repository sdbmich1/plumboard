class Conversation < ActiveRecord::Base
  attr_accessible :pixi_id, :recipient_id, :user_id, :status, :recipient_status

  before_create :activate
  has_many :posts

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :recipient, class_name: 'User', foreign_key: :recipient_id
  belongs_to :invoice, foreign_key: 'pixi_id', primary_key: 'pixi_id'

  # user id is person who starts the conversation and sends first post
  validates :user_id, :presence => true
  validates :pixi_id, :presence => true
  validates :recipient_id, :presence => true

  # default_scope order: 'created_at DESC'

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
        if post.user_id == usr.id
          return true
        end
      end
    end
    return false
  end

  # returns the other user that is a part of this conversation
  def other_user usr
    if usr.id == user_id
      return recipient
    else
      return user
    end
  end

  # checks whether user can bill
  def can_bill? usr
    if listing.status != 'active' || invoice != nil || (invoice != nil && invoice.status != 'unpaid')
      return false
    end
    listing.seller_id == usr.id
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
    posts.first.content.length > val ? posts.first.summary_custom(val) + '...' : posts.first.summary_custom(val) rescue nil
  end

  # returns whether conversation has any associated unread posts
  def any_unread? usr
    posts.each do |post| 
      if post.unread? usr
        return true
      end
    end
    return false
  end

  # select active conversations
  def self.active
    include_list.where("status = 'active' OR recipient_status = 'active'")
  end

  # eager load assns
  def self.include_list
    includes(:posts, :user, :recipient)
  end

  # get all conversations for user where status or recipient status is active
  def self.get_conversations usr
    inc_list.active.where("recipient_id = ? OR user_id = ?", usr, usr.id)
  end

  # get conversations where user has sent/received at least one message in conversation and conversation is active
  # for the user
  def self.get_specific_conversations usr, c_type 
    conv_ids = Array.new
    convos = Conversation.get_conversations(usr)
    convos.each do |convo|
      convo.posts.each do |post|
        if c_type == "received" && post.recipient_id == usr.id && convo.recipient_status == 'active'
          if (usr.id == convo.user_id && convo.status == 'active') || (usr.id == convo.recipient_id && convo.recipient_status == 'active')
              conv_ids << convo.id
              break
          end
        end
        if c_type == "sent" && post.user_id == usr.id 
          if (usr.id == convo.user_id && convo.status == 'active') || (usr.id == convo.recipient_id && convo.recipient_status == 'active')
              conv_ids << convo.id
              break
          end
        end
      end
    end
    return convos.where(["id in (?)", conv_ids]).sort_by {|x| x.posts.first.created_at }.reverse 
  end

  # set list of included assns for eager loading
  def self.inc_list
    # includes(:invoice => [:listing, :buyer, :seller], 
    includes(:listing, :invoice => [:buyer, :seller], :user => [:pictures], :recipient => [:pictures])
  end

  # set list of included assns for eager loading
  def self.inc_show_list
    includes(:posts => {:user => :pictures})
  end

  def self.remove_conv conv, user 
    if user.id == conv.user_id
      if conv.update_attributes(status: 'removed')
        conv.remove_posts(user)
        return true
      else
        return false
      end
    elsif user.id == conv.recipient_id 
      if conv.update_attributes(recipient_status: 'removed')
        conv.remove_posts(user)
        return true
      else
        return false
      end
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
    !posts.blank? ? posts.first.created_at : Date.today
  end
end
