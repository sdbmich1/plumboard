class Transaction < ActiveRecord::Base
  resourcify
  include CalcTotal, Payment, AddressManager

  attr_accessor :cvv, :card_number, :exp_month, :exp_year, :mobile_phone
  attr_accessible :address, :address2, :amt, :city, :code, :country, :credit_card_no, :description, :email, :first_name, 
  	:home_phone, :last_name, :payment_type, :promo_code, :state, :work_phone, :zip, :user_id, :confirmation_no, :token, :status,
	:convenience_fee, :processing_fee, :transaction_type, :debit_token, :cvv, :card_number, :exp_month, :exp_year, :mobile_phone, :updated_at

  belongs_to :user
  has_many :invoices
  has_many :listings, through: :invoices
  has_many :temp_listings
  has_many :transaction_details, dependent: :destroy
  has_many :pixi_payments, dependent: :destroy

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
    if usr
      txn = usr.transactions.build

      # set transaction amounts
      txn.amt = CalcTotal::process_order order
      txn.processing_fee = CalcTotal::get_processing_fee order[:inv_total]
      txn.convenience_fee = CalcTotal::get_convenience_fee order[:inv_total]
      txn.transaction_type = order[:transaction_type]

      # load user info
      txn.user_id = usr.id
      txn.first_name, txn.last_name, txn.email = usr.first_name, usr.last_name, usr.email
      txn = AddressManager::synch_address txn, usr.contacts[0], false if usr.has_address?
    end
    txn
  end

  # add each transaction item
  def add_details item, qty, val
    if item && val
      item_detail = self.transaction_details.build rescue nil
      item_detail.item_name, item_detail.quantity, item_detail.price = item, qty, val if item_detail
    end
    item_detail
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

  # check for token
  def has_token?
    if token.blank?
      errors.add :base, "Card info is missing or invalid. Please re-enter."
      false
    else
      if card_number.blank?  
        user.has_card_account? ? true : false
      else
        token
      end
    end
  end

  # save transaction
  def save_transaction order
    if valid?
      # add transaction details      
      (1..order[:cnt].to_i).each do |i| 
        if order['quantity'+i.to_s].to_i > 0 
          add_details order['item'+i.to_s], order['quantity'+i.to_s], order['price'+i.to_s].to_f 
        end 
      end 

      # get listing
      listing = Listing.where(pixi_id: order['id1']).first

      # submit payment or order based on transaction type
      if pixi? 
        self.status = 'pending' # set status
        save!  

   	# submit order
	unless self.errors.any?
          listing.submit_order(self.id) if listing
	end
      else
        # process credit card
        if has_token? 
          if process_transaction
            inv = Invoice.find(order["invoice_id"])
            inv.submit_payment(self.id) if inv
          else
            errors.add :base, "Transaction processing failed. Please re-enter."
            false
          end
        else
          false
        end
      end
    else
      false
    end
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
  
  # process transaction
  def process_transaction
    if valid? 
      # get card token
      cid = txn.user.card_accounts.get_default_acct.token rescue token
      
      # charge the credit card
      result = Payment::charge_card(cid, amt, description, self) if amt > 0.0

      # check for errors
      return false if self.errors.any?

      # check result - update confirmation # if nil (free transactions) use timestamp instead
      if result
        self.confirmation_no = result.id 

        if CREDIT_CARD_API == 'balanced'
	  self.payment_type, self.credit_card_no, self.debit_token = result.source.card_type, result.source.last_four, result.uri
	else
	  self.payment_type, self.credit_card_no = result.card[:type], result.card[:last4]
	end
      else
        if amt > 0.0
	  return false
	else
          self.confirmation_no = Time.now.to_i.to_s   
	end
      end  

      # set status
      self.status = 'approved'
      save!  
    else
      false
    end
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
    where("updated_at >= ? AND updated_at <= ?", start_date, end_date)
  end

  # set json string
  def as_json(options={})
    super(except: [:updated_at], 
      methods: [:pixi_title, :buyer_name, :seller_name, :txn_dt, :get_invoice, :get_invoice_listing]) 
  end

  def as_csv(options={})
    { "Transaction Date" => updated_at.strftime("%F"), "Item Title" => pixi_title, "Buyer" => buyer_name, "Seller" => seller_name, 
      "Price" => get_invoice.price, "Quantity" => get_invoice.quantity, "Buyer Total" => amt, 
      "Seller Total" => get_invoice.amount - get_invoice.get_fee(true) }
  end

  def self.filename
    'Transactions_' + ResetDate::display_date_by_loc(Time.now, Geocoder.coordinates("San Francisco, CA"), false).strftime("%Y_%m_%d")
  end
end
