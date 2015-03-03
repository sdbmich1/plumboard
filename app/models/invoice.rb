class Invoice < ActiveRecord::Base
  resourcify
  include CalcTotal, ResetDate
  before_create :set_flds
  after_commit :mark_as_closed, :on => :update

  attr_accessor :buyer_name, :tmp_buyer_id
  attr_accessible :amount, :buyer_id, :comment, :pixi_id, :price, :quantity, :seller_id, :status, :buyer_name,
    :sales_tax, :tax_total, :subtotal, :inv_date, :transaction_id, :bank_account_id, :tmp_buyer_id, :ship_amt, :other_amt,
    :invoice_details_attributes, :invoice_details_count

  belongs_to :seller, foreign_key: "seller_id", class_name: "User"
  belongs_to :buyer, foreign_key: "buyer_id", class_name: "User"
  belongs_to :transaction
  belongs_to :bank_account
  has_many :pixi_payments
  has_many :invoice_details
  accepts_nested_attributes_for :invoice_details, allow_destroy: true, :reject_if => :all_blank

  has_many :listings, through: :invoice_details

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
    self.status = 'unpaid' if status.nil?
    self.inv_date = Time.now if inv_date.blank?
    self.bank_account_id = seller.bank_accounts.first.id if seller.has_bank_account?
  end

  # validate picture exists
  def must_have_pixis
    if !any_pixi?
      errors.add(:base, 'Must have a pixi')
      false
    else
      true
    end
  end

  # check for a pixi
  def any_pixi?
    invoice_details.detect { |x| x && !x.pixi_id.nil? }
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
  def self.load_new usr, buyer_id, pixi_id
    if usr && usr.has_pixis?
      # get most recent pixi
      pixi = usr.active_listings.first if usr.active_listings.size == 1

      # load invoice with pixi data
      inv = usr.invoices.build buyer_id: buyer_id

      # set pixi id if possible
      det = inv.invoice_details.build
      det.pixi_id = !pixi_id.blank? ? pixi_id : !pixi.blank? ? pixi.id : nil rescue nil
      det.quantity = det.listing.pixi_wants.where(user_id: buyer_id).first.quantity rescue 1
      det.price = det.listing.price if det.listing
      det.subtotal = inv.amount = det.listing.price * det.quantity if det.listing
    end
    inv
  end

  # define eager load assns
  def self.inc_list
    includes(:buyer => :pictures, :seller => :pictures, :invoice_details => {:listing => :pictures})
  end

  # get invoices for given user
  def self.get_invoices usr
    includes(:buyer).where("invoices.seller_id = ? AND invoices.status != ?", usr.id, 'removed')
  end

  # get invoices for given buyer
  def self.get_buyer_invoices usr
    includes(:seller).where("invoices.buyer_id = ? AND invoices.status != ?", usr.id, 'removed')
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
      txn_fee = CalcTotal::get_convenience_fee amount, pixan_id

      # process payment
      result = bank_account.credit_account(amount - txn_fee) rescue 0
    else
      false
    end
  end

  # get convenience fee based on user
  def get_conv_fee usr
    owner?(usr) ? get_fee(true) : get_fee rescue 0
  end

  # get txn fee
  def get_fee sellerFlg=false
    fee = 0.0
    if amount
      if sellerFlg
        invoice_details.each do |x|
          fee += CalcTotal::get_convenience_fee(x.subtotal, x.listing.pixan_id) unless x.listing.pixan_id.blank?
        end
      end
      fee += CalcTotal::get_convenience_fee(amount) 
      fee += CalcTotal::get_processing_fee(amount) unless sellerFlg
      fee.round(2)
    else
      0.0
    end
  end

  # get txn processing fee
  def get_processing_fee
    fee = amount ? CalcTotal::get_processing_fee(amount).round(2) : 0.0
  end

  # get txn convenience fee
  def get_convenience_fee
    fee = amount ? CalcTotal::get_convenience_fee(amount).round(2) : 0.0
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

  # get pixan id
  def pixan_id
    x = listings.detect {|x| !x.pixan_id.blank? } rescue nil
    x.pixan_id if x
  end

  # get title
  def pixi_title
    listings.first.title rescue nil
  end

  # get short pixi title
  def short_title
    listings.first.short_title rescue nil
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
    Invoice.find_each do |inv|
      inv.invoice_details.create pixi_id: inv.pixi_id, quantity: inv.quantity, price: inv.price, subtotal: inv.subtotal
    end
  end

  # marked as closed any other invoice associated with this pixi
  def mark_as_closed 
    if paid?
      listings.find_each do |listing|
        inv_list = Invoice.where(status: 'unpaid').joins(:invoice_details).where("`invoice_details`.`pixi_id` = ?", listing.pixi_id).readonly(false)
        inv_list.find_each do |inv|
          inv.update_attribute(:status, 'closed') if inv.pixi_count == 1 && inv.id != self.id
        end
      end
    end
  end

  # set json string
  def as_json(options={})
    super(except: [:updated_at], 
      methods: [:pixi_title, :buyer_name, :seller_name, :short_title, :nice_status, :inv_dt, :get_fee, :get_processing_fee, :get_convenience_fee], 
      include: {seller: { only: [:first_name], methods: [:photo] }, 
                buyer: { only: [:first_name], methods: [:photo] }})
  end
end
