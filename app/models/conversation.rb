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
    includes(:user, :listing, :recipient, :invoice)
  end

  # get all conversations for user where status or recipient status is active
  def self.get_conversations usr
    #inc_list.where(:recipient_id=>usr or :user_id => usr)
    active.inc_list.where("recipient_id = ? OR user_id = ?", usr, usr.id);
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
    return convos.where(["id in (?)", conv_ids]) 
  end

  # set list of included assns for eager loading
  def self.inc_list
    includes(:invoice => [:listing, :buyer, :seller], :listing => [:pictures], :user => [:pictures], :recipient => [:pictures], :posts => [:user, :recipient])
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
end
