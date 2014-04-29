class Post < ActiveRecord::Base
  resourcify
  acts_as_readable :on => :created_at

  attr_accessible :content, :user_id, :pixi_id, :recipient_id, :msg_type

  PIXI_POST = PIXI_KEYS['pixi']['pixi_post']

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :recipient, class_name: 'User', foreign_key: :recipient_id
  belongs_to :invoice, foreign_key: 'pixi_id', primary_key: 'pixi_id'

  validates :content, :presence => true 
  validates :user_id, :presence => true
  validates :pixi_id, :presence => true
  validates :recipient_id, :presence => true

  default_scope order: 'posts.created_at DESC'

  # load default content
  def self.load_new listing
    listing.posts.build recipient_id: listing.seller_id if listing
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

  # get sender name
  def sender_name
    user.name if user
  end

  # get recipient name
  def recipient_name
    recipient.name if recipient
  end

  # get pixi title
  def pixi_title
    listing.title if listing
  end

  # set list of included assns for eager loading
  def self.inc_list
    includes(:invoice => [:listing, :buyer, :seller], :listing => [:pictures], :user => [:pictures], :recipient => [:pictures])
  end

  # get sent posts for user
  def self.get_sent_posts usr
    inc_list.where(:user_id=>usr)
  end

  # get posts for recipient
  def self.get_posts usr
    inc_list.where(:recipient_id=>usr)
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
      # new post
      post = listing.posts.build recipient_id: recipient, user_id: sender, msg_type: msgType

      # set amount format
      amt = "%0.2f" % inv.amount

      #set content
      post.content = msg + amt

      # add post
      post.save!
    else
      false
    end
  end

  # send invoice post
  def self.send_invoice inv, listing
    if !inv.blank? && !listing.blank?

      # set content msg 
      msg = "You received Invoice ##{inv.id} from #{inv.seller.name} for $"

      # add post
      add_post inv, listing, inv.seller_id, inv.buyer_id, msg, 'inv'
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
      add_post inv, listing, inv.buyer_id, inv.seller_id, msg, 'paidinv'
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
end
