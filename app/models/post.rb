class Post < ActiveRecord::Base
  resourcify
  acts_as_readable :on => :created_at

  attr_accessible :content, :user_id, :pixi_id, :recipient_id, :msg_type, :conversation_id, :status, :recipient_status

  PIXI_POST = PIXI_KEYS['pixi']['pixi_post']
  MAX_SIZE = 100

  before_create :activate

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :recipient, class_name: 'User', foreign_key: :recipient_id
  belongs_to :invoice, foreign_key: 'pixi_id', primary_key: 'pixi_id'
  belongs_to :conversation, :inverse_of => :posts

  validates_presence_of :conversation, :content, :user_id, :pixi_id, :recipient_id

  # default_scope order: 'posts.created_at DESC'

  # set active status
  def activate
    if self.status != 'removed'
      self.status = 'active'
    end
    if self.recipient_status != 'removed'
      self.recipient_status = 'active'
    end

    # check for invalid ascii chars
    encoding_options = {:invalid => :replace, :undef => :replace, :replace => '', :UNIVERSAL_NEWLINE_DECORATOR => true}
    self.content.encode!(Encoding.find('ASCII'), encoding_options)
    self
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
    includes(:user, :listing, :recipient, :invoice, :conversation)
  end

  # load default content
  def self.load_new listing
    listing.posts.build recipient_id: listing.seller_id if listing
  end

  # short content
  def summary num=MAX_SIZE, showTailFlg=false
    descr = long_content?(num) ? content.html_safe[0..num-1] : content.html_safe rescue nil
    descr = showTailFlg ? descr + '...' : descr rescue nil
    Rinku.auto_link(descr) if descr
  end

  # add hyperlinks to content
  def full_content
    Rinku.auto_link(content.html_safe) rescue nil
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
    active.includes(:invoice => [:listing, :buyer, :seller], :listing => [:pictures], :user => [:pictures], :recipient => [:pictures])
  end

  # get sent posts for user
  def self.get_sent_posts usr
    # inc_list.where(:user_id=>usr)
    inc_list.where("user_id = ? AND status = ?", usr, 'active')
  end

  # get posts for recipient
  def self.get_posts usr
    # inc_list.where(:recipient_id=>usr)
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
    if sender && recipient

      # find the corresponding conversation
      conv = Conversation.get_conv inv.pixi_id, recipient.id, sender.id

      # create new conversation if one doesn't already exist
      if conv.blank?
        conv = Conversation.get_conv inv.pixi_id, sender.id, recipient.id
        conv = listing.conversations.create pixi_id: listing.pixi_id, user_id: sender.id, recipient_id: recipient.id if conv.blank?
      end

      # new post
      conv.posts.create recipient_id: recipient.id, user_id: sender.id, msg_type: msgType, pixi_id: conv.pixi_id, content: msg + ("%0.2f" % inv.amount)
    else
      false
    end
  end

  # send invoice post
  def self.send_invoice inv, listing
    if !inv.blank? && !listing.blank?

      # set content msg 
      msg = "You received Invoice ##{inv.id} from #{inv.seller_name} for $"

      # add post
      add_post inv, listing, inv.seller, inv.buyer, msg, 'inv'
    else
      false
    end
  end

  # pay invoice post
  def self.pay_invoice model

    # get invoice and pixi
    inv = model.invoices[0] rescue nil
    listing = inv.listing if inv

    # send post
    if inv && listing

      # set content msg 
      msg = "You received a payment for Invoice ##{inv.id} from #{inv.buyer_name} for $"

      # add post
      add_post inv, listing, inv.buyer, inv.seller, msg, 'paidinv'
    else
      false
    end
  end

  # check if invoice is due
  def due_invoice? usr
    if invoice
      !invoice.owner?(usr) && invoice.unpaid? && invoice.buyer_name == usr.name ? true : false
    else
      false
    end
  end

  # check if invoice msg 
  def inv_msg?
    msg_type == 'inv'
  end

  # check if want msg 
  def want_msg?
    msg_type == 'want'
  end

  # check if system msg 
  def system_msg?
    %w(approve deny system).detect {|x| msg_type == x}
  end

  # set json string
  def as_json(options={})
    super(except: [:updated_at], methods: [:pixi_title, :recipient_name, :sender_name], 
      include: {recipient: { only: [:first_name], methods: [:photo] }, 
                user: { only: [:first_name], methods: [:photo] }})
  end

  # map messages to conversations if needed
  def self.map_posts_to_conversations
    Post.order.reverse_order.each do |post|
      post.status = post.recipient_status = 'active'
      if post.conversation_id.nil?
    
        # finds if there is already an existing conversation for the post
        conv = Conversation.get_conv post.pixi_id, post.recipient_id, post.user_id

        # finds if there is existing conversation with swapped recipient/user
        if conv.blank?
          conv = Conversation.get_conv post.pixi_id, post.user_id, post.recipient_id
        end

        # create new conversation if one doesn't already exist
        if conv.blank?
          if listing = Listing.where(:pixi_id => post.pixi_id).first
            conv = listing.conversations.create pixi_id: post.pixi_id, user_id: post.user_id, recipient_id: post.recipient_id
	  end
        elsif conv.status != 'active' || conv.recipient_status != 'active'
          conv.status = conv.recipient_status = 'active'
          conv.save
        end

        # updates post with conversation id
        post.conversation_id = conv.id if conv
      end
      post.save
    end
  end

  # removes given posts for a specific user
  def remove_post user 
    if user.id == self.user_id
      self.update_attributes(status: 'removed')
    elsif user.id == self.recipient_id 
      self.update_attributes(recipient_status: 'removed')
    end
  end

  # return create date
  def create_dt
    new_dt = listing.display_date created_at, false rescue created_at
  end
end
