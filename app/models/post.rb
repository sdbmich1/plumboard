class Post < ActiveRecord::Base
  resourcify
  acts_as_readable :on => :created_at

  attr_accessible :content, :user_id, :pixi_id, :recipient_id

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

  # get posts for recipient
  def self.get_posts usr
    where(:recipient_id=>usr)
  end

  # get unread posts for recipient
  def self.get_unread usr
    get_posts(usr).unread_by(usr) rescue nil
  end

  # get count of unread messages
  def self.unread_count usr
    get_unread(usr).count
  end

  # add post for invoice creation or payment
  def self.add_post inv, listing, sender, recipient, msg
    if sender && recipient
      # new post
      post = listing.posts.build recipient_id: recipient, user_id: sender

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
      msg = "You received an invoice ##{inv.id} from #{inv.seller.name} for $"

      # add post
      add_post inv, listing, inv.seller_id, inv.buyer_id, msg
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
    if !inv.blank? && !listing.blank?

      # set content msg 
      msg = "You received a payment for Invoice ##{inv.id} from #{inv.buyer.name} for $"

      # add post
      add_post inv, listing, inv.buyer_id, inv.seller_id, msg
    else
      false
    end
  end

  # check if invoice is due
  def due_invoice? usr
    if invoice
      !invoice.owner?(usr) && invoice.unpaid? ? true : false
    else
      false
    end
  end
end
