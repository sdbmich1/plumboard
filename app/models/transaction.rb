class Transaction < ActiveRecord::Base
  include CalcTotal, Payment

  attr_accessor :cvv, :card_number, :card_month, :card_year
  attr_accessible :address, :address2, :amt, :city, :code, :country, :credit_card_no, :description, :email, :first_name, 
  	:home_phone, :last_name, :payment_type, :promo_code, :state, :work_phone, :zip, :user_id, :confirmation_no, :token, :status,
	:convenience_fee, :processing_fee, :transaction_type, :debit_token, :cvv, :card_number, :card_month, :card_year

  belongs_to :user
  has_many :invoices
  has_many :listings, through: :invoices
  has_many :temp_listings
  has_many :transaction_details

  name_regex =  /^[A-Z]'?['-., a-zA-Z]+$/i
  text_regex = /^[-\w\,. _\/&@]+$/i

  # validate added fields           
  validates :first_name,  :presence => true,
            :length   => { :maximum => 30 },
            :format => { :with => name_regex }  

  validates :last_name,  :presence => true,
            :length   => { :maximum => 30 },
            :format => { :with => name_regex }

  validates :email, :presence => true, :email_format => true
  validates :address,  :presence => true,
                    :length   => { :maximum => 50 }
  validates :city,  :presence => true,
                    :length   => { :maximum => 50 },
                    :format => { :with => name_regex }  

  validates :state, :presence => true
  validates :zip,   :presence => true,
                    :length   => { :maximum => 12 }

  validates :home_phone, :presence => true
  validates :amt, :presence => true,
  		  :numericality => true

  # pre-load new transaction for given user
  def self.load_new usr, listing, order
    if usr && listing
      txn = listing.build_transaction

      # set transaction amounts
      txn.amt = CalcTotal::process_order order
      txn.processing_fee = CalcTotal::get_processing_fee order[:inv_total]
      txn.convenience_fee = CalcTotal::get_convenience_fee order[:inv_total]
      txn.transaction_type = order[:transaction_type]

      # load user info
      txn.user_id = usr.id
      txn.first_name, txn.last_name, txn.email = usr.first_name, usr.last_name, usr.email
      
      # load user contact info
      if usr.contacts[0]
        txn.address, txn.address2 = usr.contacts[0].address, usr.contacts[0].address2
        txn.city, txn.state = usr.contacts[0].city, usr.contacts[0].state
        txn.zip, txn.home_phone = usr.contacts[0].zip, usr.contacts[0].home_phone
        txn.country = usr.contacts[0].country
      end
    end
    txn
  end

  # add each transaction item
  def add_details item, qty, val
    if item && qty && val
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

  def valid_card?
    card_number.blank? || cvv.blank? || (card_month < Date.today.month && card_year <= Date.today.year) ? false : true
  end

  # check for token
  def has_token?
    Rails.logger.info 'Token = ' + self.token
    if token.blank?
      errors.add :base, "Card info is missing or invalid. Please re-enter."
      false
    else
      user.has_card_account? ? true : CardAccount.add_card(self, self.token)
    end
  end

  # save transaction
  def save_transaction order, listing
    if valid?
      # add transaction details      
      (1..order[:cnt].to_i).each do |i| 
        if order['quantity'+i.to_s].to_i > 0 
          add_details order['item'+i.to_s], order['quantity'+i.to_s], order['price'+i.to_s].to_f * order['quantity'+i.to_s].to_i
        end 
      end 

      # submit payment or order based on transaction type
      if pixi? 
        self.status = 'pending' # set status
        save!  

 	# submit order
        listing.submit_order(self.id) unless self.errors.any?
      else
        # process credit card
	if has_token? 
          if process_transaction
	    inv = listing.get_invoice(order["invoice_id"])

	    # submit payment
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

  # get invoice seller
  def seller_name
    get_invoice.seller_name rescue nil
  end

  # get buyer name
  def buyer_name
    first_name + ' ' + last_name rescue nil
  end

  # get invoice pixi id
  def pixi_id
    get_invoice.pixi_id rescue nil
  end

  # get invoice seller id
  def seller_id
    get_invoice.seller_id rescue nil
  end

  # check if address is populated
  def has_address?
    !address.blank? && !city.blank? && !state.blank? && !zip.blank?
  end
  
  # process transaction
  def process_transaction
    if valid? 
      Rails.logger.info 'Processing fee = ' + self.processing_fee.to_s

      # charge the credit card
      result = Payment::charge_card(token, amt, description, self) if amt > 0.0

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
  def txn_dt
    created_at.utc.getlocal.strftime('%m/%d/%Y') rescue nil
  end

  # get txn fees
  def get_fee
    convenience_fee + processing_fee rescue nil
  end

  # set json string
  def as_json(options={})
    super(except: [:updated_at], 
      methods: [:pixi_title, :buyer_name, :seller_name, :txn_dt, :get_invoice, :get_invoice_listing]) 
  end
end
