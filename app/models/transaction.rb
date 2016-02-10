class Transaction < ActiveRecord::Base
  resourcify

  attr_accessor :cvv, :card_number, :exp_month, :exp_year, :mobile_phone, :seller_token, :seller_inv_amt
  attr_accessible :address, :address2, :amt, :city, :code, :country, :credit_card_no, :description, :email, :first_name, 
    :home_phone, :last_name, :payment_type, :promo_code, :state, :work_phone, :zip, :user_id, :confirmation_no, :token, :status,
    :convenience_fee, :processing_fee, :transaction_type, :debit_token, :cvv, :card_number, :exp_month, :exp_year, :mobile_phone, :updated_at,
    :seller_token, :seller_inv_amt, :recipient_first_name, :recipient_last_name, :recipient_email,
    :ship_address, :ship_address2, :ship_city, :ship_state, :ship_zip, :ship_country, :recipient_phone

  belongs_to :user
  has_many :invoices
  has_many :listings, through: :invoices
  has_many :temp_listings
  has_many :transaction_details, dependent: :destroy
  has_many :pixi_payments, dependent: :destroy

  after_commit :sync_ship_address, on: :create, if: :has_ship_address?

  name_regex =  /^[A-Z]'?['-., a-zA-Z]+$/i
  text_regex = /^[-\w\,. _\/&@]+$/i

  # validate added fields           
  validates :first_name,  :presence => true,
            :length   => { :maximum => 30 },
            :format => { :with => name_regex }  

  validates :last_name,  :presence => true,
            :length   => { :maximum => 80 },
            :format => { :with => name_regex }

  validates :email, :presence => true, :email_format => true
  validates :address,  :presence => true,
                    :length   => { :maximum => 50 }
  validates :address2, allow_blank: true, length: { :maximum => 50 }
  validates :city,  :presence => true,
                    :length   => { :maximum => 50 },
                    :format => { :with => name_regex }  

  validates :state, :presence => true
  validates :zip, presence: true, length: {in: 5..10}
  validates :home_phone, presence: true, length: {in: 10..15}
  validates :mobile_phone, allow_blank: true, length: {in: 10..15}
  validates :work_phone, allow_blank: true, length: {in: 10..15}
  validates :amt, presence: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
  		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }  
  validates :convenience_fee, presence: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ },
   		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: (MAX_PIXI_AMT/10).to_f } 
  validates :processing_fee, presence: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
   		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: (MAX_PIXI_AMT/10).to_f } 

  # define eager load assns
  def self.inc_list
    includes(:invoices => {:listings => :pictures})
  end

  # override find method
  def self.find id
    inc_list.where(id: id.to_i).first
  end

  # pre-load new transaction for given user
  def self.load_new usr, order
    txn = usr ? TransactionProcessor.new(usr.transactions.build).load_data(usr, order) : Transaction.new
  end
  
  # check if transaction is refundable
  def refundable? 
    new_dt = created_at + 30.days rescue nil
    new_dt ? new_dt > Date.today() : false
  end

  # check transaction type
  def pixi?
    transaction_type == 'pixi'
  end

  # check for valid card
  def valid_card?
    card_number.blank? || cvv.blank? || (exp_month < Date.today.month && exp_year <= Date.today.year) ? false : true
  end
  
  # process transaction
  def process_transaction
    valid? ? TransactionProcessor.new(self).process_data : false
  end

  # save transaction
  def save_transaction order
    valid? ? TransactionProcessor.new(self).save_data(order) : false
  end

  # set approval status
  def approved?
    status == 'approved'
  end

  # get invoice pixi
  def get_invoice_listing
    listings.first rescue nil
  end

  # get primary invoice
  def get_invoice
    invoices.first rescue nil
  end

  # get invoice pixi title
  def pixi_title
    get_invoice_listing.title rescue nil
  end

  # get invoice seller
  def seller
    get_invoice.seller rescue nil
  end

  # get invoice seller name
  def seller_name
    get_invoice.seller_name rescue nil
  end

  # get buyer name
  def buyer_name
    first_name + ' ' + last_name rescue nil
  end

  # get invoice pixi id
  def pixi_id
    get_invoice_listing.pixi_id rescue nil
  end

  # get invoice seller id
  def seller_id
    get_invoice.seller_id rescue nil
  end

  # check if address is populated
  def has_address?
    !address.blank? && !city.blank? && !state.blank? && !zip.blank? && !home_phone.blank?
  end

  # format txn date
  def txn_dt flg=true
    new_dt = get_invoice_listing.display_date created_at, flg rescue created_at
  end

  # get txn fees
  def get_fee
    convenience_fee + processing_fee rescue 0
  end

  # check amount
  def has_amount?
    amt > 0 rescue nil
  end

  def self.get_by_date start_date, end_date
    includes(:invoices => [{:invoice_details => :listing}, :seller]).where("updated_at >= ? AND updated_at <= ?", start_date, end_date)
  end

  def cust_token
    user.cust_token rescue nil
  end

  # set json string
  def as_json(options={})
    super(except: [:updated_at], 
      methods: [:pixi_title, :buyer_name, :seller_name, :txn_dt, :get_invoice, :get_invoice_listing],
      include: { listings: { only: [:pixi_id], methods: [:photo_url] }})
  end

  def as_csv(options={})
    { "Transaction Date" => updated_at.strftime("%F"), "Item Title" => pixi_title,
      "Buyer" => buyer_name, "Seller" => seller_name, "Buyer Total" => amt, 
      "Seller Total" => get_invoice.amount - get_invoice.get_fee(true) }
  end

  def self.filename
    'Transactions_' + ResetDate::display_date_by_loc(Time.now, Geocoder.coordinates("San Francisco, CA"), false).strftime("%Y_%m_%d")
  end

  def has_ship_address?
    !(ship_address && ship_city && ship_state && ship_zip).blank?
  end

  def sync_ship_address
    TransactionProcessor.new(self).sync_ship_address
  end

  def recipient_name
    [recipient_first_name, recipient_last_name].join(' ')
  end
end
