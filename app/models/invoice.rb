class Invoice < ActiveRecord::Base
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

  validates :pixi_id, presence: true  
  validates :buyer_id, presence: true  
  validates :seller_id, presence: true  
  validates :price, presence: true, :numericality => { greater_than: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }    
  validates :amount, presence: true, :numericality => { greater_than: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }  
  validates :quantity, presence: true, :numericality => { greater_than: 0, less_than_or_equal_to: MAX_INV_QTY.to_i }    
  validates :sales_tax, allow_blank: true, :numericality => { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }    

  # set flds
  def set_flds
    self.status = 'unpaid' if status.nil?
  end

  # get by status
  def self.get_by_status val
    where(:status=>val)
  end

  # get invoice by order id
  def self.find_invoice order
    find(order['invoice_id']) rescue nil
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
      bank_account.credit_account amount
    else
      false
    end
  end
end
