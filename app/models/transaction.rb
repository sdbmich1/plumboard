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
      new_transaction = listing.build_transaction

      # set transaction amounts
      new_transaction.amt = CalcTotal::process_order order
      new_transaction.processing_fee = CalcTotal::get_processing_fee
      new_transaction.convenience_fee = CalcTotal::get_convenience_fee
      new_transaction.transaction_type = order[:transaction_type]

      # load user info
      new_transaction.user_id = usr.id
      new_transaction.first_name, new_transaction.last_name, new_transaction.email = usr.first_name, usr.last_name, usr.email
      
      # load user contact info
      if usr.contacts[0]
        new_transaction.address, new_transaction.address2 = usr.contacts[0].address, usr.contacts[0].address2
        new_transaction.city, new_transaction.state = usr.contacts[0].city, usr.contacts[0].state
        new_transaction.zip, new_transaction.home_phone = usr.contacts[0].zip, usr.contacts[0].home_phone
        new_transaction.country = usr.contacts[0].country
      end
    end
    new_transaction
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

  # check for token
  def has_token?
    if token.blank?
      card_num = card_number[card_number.length-4..card_number.length]
      unless card = user.card_accounts.where(:card_no => card_num).first
	card = user.card_accounts.build card_number: self.card_number, expiration_month: self.card_month,
	         expiration_year: self.card_year, card_code: self.cvv, zip: self.zip 
	card.save_account 
      end
      self.token = card.token
    else
      true 
    end
  end

  # save transaction
  def save_transaction order, listing
    if has_token? && valid?
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
        if process_transaction
	  inv = listing.get_invoice(order["invoice_id"])

	  # submit payment
	  inv.submit_payment(self.id) if inv
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

  # check if address is populated
  def has_address?
    !(address.blank? && city.blank? && state.blank? && zip.blank?)
  end
  
  # process transaction
  def process_transaction
    if valid? 
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

  # set json string
  def as_json(options={})
    super(except: [:updated_at], 
      methods: [:pixi_title, :buyer_name, :seller_name, :txn_dt, :get_invoice, :get_invoice_listing]) 
  end
end
