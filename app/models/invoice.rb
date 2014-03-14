class Invoice < ActiveRecord::Base
  include CalcTotal
  before_create :set_flds

  attr_accessor :buyer_name
  attr_accessible :amount, :buyer_id, :comment, :pixi_id, :price, :quantity, :seller_id, :status, :buyer_name,
    :sales_tax, :tax_total, :subtotal, :inv_date, :transaction_id, :bank_account_id

  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :seller, foreign_key: "seller_id", class_name: "User"
  belongs_to :buyer, foreign_key: "buyer_id", class_name: "User"
  belongs_to :transaction
  belongs_to :bank_account

  has_many :posts, foreign_key: "pixi_id", primary_key: "pixi_id"
  has_many :pixi_payments

  validates :pixi_id, presence: true  
  validates :buyer_id, presence: true  
  validates :seller_id, presence: true  
  validates :price, presence: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
    		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }
  validates :amount, presence: true, :numericality => { greater_than: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }  
  validates :quantity, presence: true, :numericality => { greater_than: 0, less_than_or_equal_to: MAX_INV_QTY.to_i }    
  validates :sales_tax, allow_blank: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
    		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  default_scope order: 'invoices.created_at DESC'

  # set flds
  def set_flds
    self.status = 'unpaid' if status.nil?
    self.inv_date = Time.now if inv_date.blank?
    self.bank_account_id = seller.bank_accounts.first.id if seller.has_bank_account?
  end

  # get by status
  def self.get_by_status val
    where(:status=>val)
  end

  # get invoice by order id
  def self.find_invoice order
    find(order['invoice_id']) rescue nil
  end

  # load new invoice with most recent pixi data
  def self.load_new usr
    if usr && usr.has_pixis?
      # get most recent pixi
      pixi = usr.active_listings.first

      # load invoice with pixi data
      inv = usr.invoices.build pixi_id: pixi.pixi_id, price: pixi.price, subtotal: pixi.price, amount: pixi.price
    end
    inv
  end

  # get invoices for given user
  def self.get_invoices usr
    where(:seller_id=>usr) rescue nil
  end

  # check if invoice owner
  def owner? usr
    seller_id == usr.id
  end

  # check if invoice is paid
  def paid?
    status == 'paid'
  end

  # check if invoice is unpaid
  def unpaid?
    status == 'unpaid'
  end

  # submit payment request for review
  def submit_payment val

    # set transaction id
    if val
      self.transaction_id, self.status = val, 'paid' 
      save!
    else
      false
    end
  end

  # credit account
  def credit_account
    if amount
      # calculate fee
      txn_fee = CalcTotal::get_convenience_fee amount

      # process payment
      result = bank_account.credit_account (amount - txn_fee)
    else
      false
    end
  end

  # get txn fee
  def get_fee
    if amount
      # calculate fee
      fee = CalcTotal::get_convenience_fee(amount) + CalcTotal::get_processing_fee(amount)
      fee.round(2)
    else
      0.0
    end
  end

  # get txn processing fee
  def get_processing_fee
    if amount
      fee = CalcTotal::get_processing_fee amount
      fee.round(2)
    else
      0.0
    end
  end

  # get txn convenience fee
  def get_convenience_fee
    if amount
      fee = CalcTotal::get_convenience_fee(amount)
      fee.round(2)
    else
      0.0
    end
  end

  # get buyer name
  def buyer_name
    buyer.name rescue nil
  end

  # get seller name
  def seller_name
    seller.name rescue nil
  end

  # get seller email
  def seller_email
    seller.email rescue nil
  end

  # get title
  def pixi_title
    listing.title rescue nil
  end

  # get short pixi title
  def short_title
    listing.short_title rescue nil
  end

  # titleize status
  def nice_status
    status.titleize rescue nil
  end

  # format inv date
  def inv_dt
    inv_date.utc.getlocal.strftime('%m/%d/%Y') rescue nil
  end

  # set json string
  def as_json(options={})
    super(except: [:updated_at], 
      methods: [:pixi_title, :buyer_name, :seller_name, :short_title, :nice_status, :inv_dt, :get_fee, :get_processing_fee, :get_convenience_fee], 
      include: {seller: { only: [:first_name], methods: [:photo] }, 
                buyer: { only: [:first_name], methods: [:photo] },
                listing: { only: [:description], methods: [:photo_url] }})
  end
end
