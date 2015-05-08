class PixiPayment < ActiveRecord::Base
  include ResetDate
  attr_accessible :amount, :buyer_id, :invoice_id, :pixi_fee, :pixi_id, :seller_id, :token, :transaction_id, :confirmation_no

  # belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :seller, foreign_key: "seller_id", class_name: "User"
  belongs_to :buyer, foreign_key: "buyer_id", class_name: "User"
  belongs_to :transaction
  belongs_to :invoice

  # validates :pixi_id, presence: true  
  validates :buyer_id, presence: true  
  validates :seller_id, presence: true  
  validates :transaction_id, presence: true  
  validates :invoice_id, presence: true  
  validates :pixi_fee, presence: true
  validates :amount, presence: true
  validates :token, presence: true

  # add txn
  def self.add_transaction inv, fee, token, cid
    if token
      new_payment = inv.pixi_payments.build buyer_id: inv.buyer_id, seller_id: inv.seller_id, 
        transaction_id: inv.transaction_id, amount: inv.amount, pixi_fee: fee, token: token, confirmation_no: cid
      new_payment.save!
    else
      false
    end
  end

  # bank account number
  def acct_no
    bank_account.account_number rescue nil
  end

  # bank name
  def bank_name
    bank_account.bank_name rescue nil
  end

  # amount
  def amt
    amount.to_f/100 rescue 0.0
  end

  # format updated date
  def created_dt
    lat, lng = listing.lat, listing.lng
    ResetDate::format_date created_at, [lat, lng].to_zip 
  end
end
