class Invoice < ActiveRecord::Base
  resourcify
  before_create :set_flds
  after_commit :mark_as_closed, :on => :update

  attr_accessor :buyer_name, :tmp_buyer_id, :decline_reason
  attr_accessible :amount, :buyer_id, :comment, :pixi_id, :price, :quantity, :seller_id, :status, :buyer_name,
    :sales_tax, :tax_total, :subtotal, :inv_date, :transaction_id, :bank_account_id, :tmp_buyer_id, :ship_amt, :other_amt,
    :invoice_details_attributes, :invoice_details_count

  belongs_to :seller, foreign_key: "seller_id", class_name: "User"
  belongs_to :buyer, foreign_key: "buyer_id", class_name: "User"
  belongs_to :transaction
  belongs_to :bank_account
  has_many :pixi_payments
  has_many :invoice_details
  has_many :listings, through: :invoice_details
  accepts_nested_attributes_for :invoice_details, allow_destroy: true, :reject_if => :all_blank

  validates :buyer_id, presence: true  
  validates :seller_id, presence: true  
  validates :amount, presence: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
  		numericality: { greater_than: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }  
  validates :sales_tax, allow_blank: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
    		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_SALES_TAX.to_i }
  validates :ship_amt, allow_blank: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
    		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_SHIP_AMT.to_i }
  validate :must_have_pixis

  default_scope order: 'invoices.created_at DESC'

  # set flds
  def set_flds
    InvoiceProcessor.new(self).set_flds
  end

  # validate picture exists
  def must_have_pixis
    InvoiceProcessor.new(self).must_have_pixis
  end

  # check for a pixi
  def any_pixi?
    InvoiceProcessor.new(self).must_have_pixis
  end

  # get by status
  def self.get_by_status val
    where(:status=>val)
  end

  # get invoice by order id
  def self.find_invoice order
    if order['transaction_type'] == 'invoice'
      find(order['invoice_id']) rescue nil
    end
  end

  # load new invoice with most recent pixi data
  def self.load_new usr, buyer_id, pixi_id, fulfillment_type_code=nil
    InvoiceProcessor.new(self).load_new usr, buyer_id, pixi_id, fulfillment_type_code
  end

  # define eager load assns
  def self.inc_list
    includes(:listings => :category, :buyer => :pictures, :seller => :pictures, :invoice_details => {:listing => :pictures})  
  end

  # get invoices for given user
  def self.get_invoices usr
    inc_list.where("invoices.seller_id = ? AND invoices.status NOT IN ('closed','removed')", usr.id)
  end

  # get invoices for given buyer
  def self.get_buyer_invoices usr
    inc_list.where("invoices.buyer_id = ? AND invoices.status NOT IN ('closed','removed')", usr.id)
  end

  # check if invoice owner
  def owner? usr
    seller_id == usr.id rescue false
  end

  # check if invoice is paid
  def paid?
    status == 'paid' rescue false
  end

  # check if invoice is unpaid
  def unpaid?
    status == 'unpaid' rescue false
  end

  # check if invoice is declined
  def declined?
    status == 'declined' rescue false
  end

  # check if invoice has shipping
  def has_shipping?
    !ship_amt.blank? rescue false
  end

  # count pixis
  def pixi_count
    invoice_details_count rescue 0
  end

  # submit payment request for review
  def submit_payment val
    InvoiceProcessor.new(self).submit_payment val
  end

  # credit account & process payment
  def credit_account
    InvoiceProcessor.new(self).credit_account
  end

  # get convenience fee based on user
  def get_conv_fee usr
    owner?(usr) ? get_fee(true) : get_fee rescue 0
  end

  # get txn fee
  def get_fee sellerFlg=false, fee=0.0
    InvoiceProcessor.new(self).get_fee sellerFlg, fee
  end

  # get txn processing fee
  def get_processing_fee
    InvoiceProcessor.new(self).get_processing_fee
  end

  # get txn convenience fee
  def get_convenience_fee
    InvoiceProcessor.new(self).get_convenience_fee
  end

  # get buyer name
  def buyer_name
    buyer.name rescue nil
  end

  # get buyer first name
  def buyer_first_name
    buyer.first_name rescue nil
  end

  # get buyer email
  def buyer_email
    buyer.email rescue nil
  end

  # get seller name
  def seller_name
    seller.name rescue nil
  end

  # get seller first name
  def seller_first_name
    seller.first_name rescue nil
  end

  # get seller email
  def seller_email
    seller.email rescue nil
  end

  # get seller token
  def seller_token
    seller.cust_token rescue nil
  end

  # get pixan id
  def pixan_id
    InvoiceProcessor.new(self).pixan_id
  end

  # get title
  def pixi_title
    listings.first.title rescue nil
  end

  # get short pixi title
  def short_title
    listings.first.short_title(false, 20) rescue nil
  end

  # check if pixi post
  def pixi_post?
    listings.detect {|x| x.pixi_post? } rescue nil
  end

  # titleize status
  def nice_status
    status.titleize rescue nil
  end

  # format inv date
  def inv_dt
    inv_date.strftime('%m/%d/%Y') rescue nil
  end

  # format date
  def format_date dt
    listings.first.display_date dt, true
  end

  # load assn details
  def self.load_details
    InvoiceProcessor.new(self).load_details
  end

  # marked as closed any other invoice associated with this pixi
  def mark_as_closed 
    InvoiceProcessor.new(self).mark_as_closed
  end

  # return all unpaid invoices that are more than number_of_days old
  def self.unpaid_old_invoices number_of_days=2
    where("status = 'unpaid' AND created_at < ?", Time.now - number_of_days.days)
  end

  # decline options
  def decline_item_list
    ['No Longer Interested', 'Incorrect Pixi', 'Incorrect Price', 'Did Not Want']
  end

  def decline_msg
    InvoiceProcessor.new(self).decline_msg
  end

  def decline reason
    self.decline_reason = reason
    update_attribute(:status, 'declined')
  end

  # set json string
  def as_json(options={})
    super(except: [:pixi_id, :price, :quantity, :subtotal, :updated_at], 
      methods: [:pixi_title, :short_title, :nice_status, :inv_dt, :get_fee, :get_processing_fee, :get_convenience_fee, :seller_amount], 
      include: {seller: { only: [:first_name, :acct_token], methods: [:name, :photo] }, 
                buyer: { only: [:first_name], methods: [:name, :photo] },
		invoice_details: { only: [:price, :quantity, :fulfillment_type_code, :subtotal], methods: [:pixi_title] },
		listings: { only: [:pixi_id], methods: [:photo_url] }})
  end

  # get amount
  def get_pixi_amt_left pid
    listings.where(pixi_id: pid).first.amt_left rescue 1
  end

  # get seller amount minus fees
  def seller_amount
    InvoiceProcessor.new(self).seller_amount
  end

  # get description for completed txn
  def description
    transaction.description rescue nil
  end

  def bank_name
    bank_account.bank_name rescue nil
  end

  def acct_no
    bank_account.acct_no rescue nil
  end

  def confirmation_no
    transaction.confirmation_no rescue nil
  end

  def transaction_amount
    transaction.amt rescue 0.0
  end

  def self.get_by_buyer uid
    where(buyer_id: uid)
  end

  def self.get_by_seller uid
    where(seller_id: uid)
  end

  def self.get_by_pixi pid
    where("listings.pixi_id = ?", pid).joins(:listings)
  end

  def self.get_by_status_and_pixi val, uid, pid, buyerFlg=true
    str = buyerFlg ? "get_by_buyer" : 'get_by_seller'
    get_by_status(val).send(str, uid).get_by_pixi(pid) rescue nil
  end

  def self.process_invoice listing, buyer_id, fulfillment_type_code
    InvoiceProcessor.new(nil).process_invoice listing, buyer_id, fulfillment_type_code
  end
end
