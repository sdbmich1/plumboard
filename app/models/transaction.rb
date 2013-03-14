class Transaction < ActiveRecord::Base
  attr_accessor :cvv
  attr_accessible :address, :address2, :amt, :city, :code, :country, :credit_card_no, :description, :email, :first_name, 
  	:home_phone, :last_name, :payment_type, :promo_code, :state, :work_phone, :zip, :user_id, :confirmation_no, :token

  belongs_to :user
  has_many :listings
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

  validates :country, :presence => true
  validates :home_phone, :presence => true
  validates :amt, :presence => true,
  		  :numericality => true

  # pre-load new transaction for given user
  def self.load_new(usr)
    if usr
      new_transaction = usr.transactions.build

      # load user info
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

  # process transaction
  def save_transaction order
    if valid?
      # add transaction details      
      (1..order[:cnt].to_i).each do |i| 
        if order['quantity'+i.to_s].to_i > 0 
          add_details order['item'+i.to_s], order['quantity'+i.to_s], order['price'+i.to_s].to_f * order['quantity'+i.to_s].to_i
        end 
      end 

      # charge the credit card using Stripe
      if amt > 0.0 then
        result = Stripe::Charge.create(:amount => (amt * 100).to_i, :currency => "usd", :card => token, :description => description)  
      end

      # check result - update confirmation # if nil (free transactions) use timestamp instead
      if result
        self.confirmation_no, self.payment_type, self.credit_card_no = result.id, result.card[:type], result.card[:last4] 
      else
        self.confirmation_no = Time.now.to_i.to_s   
      end  
      save!  
    end

    # rescue errors
    rescue Stripe::CardError => e
      process_error e
    rescue Stripe::AuthenticationError => e
      process_error e
    rescue Stripe::InvalidRequestError => e
      process_error e
    rescue Stripe::APIConnectionError => e
      process_error e
    rescue Stripe::StripeError => e
      ExceptionNotifier::Notifier.exception_notification('StripeError', e).deliver if Rails.env.production?
      process_error e
    rescue => e
      process_error e

    # return false
    false
  end

  # process credit card messages
  def process_error e
    logger.error "Stripe error while processing this transaction: #{e.message}"
    errors.add :base, "There was a problem with your credit card. #{e.message}"    
  end

  # handle credit card error
  def check_for_stripe_error
    self.errors[:credit_card_no] = @stripe_error
  end
end
