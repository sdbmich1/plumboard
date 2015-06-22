class BankAccount < ActiveRecord::Base
  before_create :set_flds, :must_have_token

  attr_accessor :acct_number, :routing_number
  attr_accessible :acct_name, :acct_no, :acct_type, :status, :token, :user_id, :description, :acct_number, :routing_number, :bank_name,
    :default_flg, :currency_type_code, :country_code

  belongs_to :user
  has_many :invoices

  validates :user_id, presence: true
  validates :acct_name, presence: true
  validate :must_have_token

  # verify token exists before creating record
  def must_have_token
    BankProcessor.new(self).must_have_token
  end

  # set flds
  def set_flds
    BankProcessor.new(self).set_flds
  end

  # get active accounts
  def self.active
    where(:status=>'active')
  end

  # get account
  def get_account
    BankProcessor.new(self).get_account
  end

  # add new account
  def save_account ip	
    BankProcessor.new(self).save_account ip	
  end

  # issue account credit
  def credit_account amt
    BankProcessor.new(self).credit_account amt
  end

  # delete account
  def delete_account
    BankProcessor.new(self).delete_account
  end

  # account owner name
  def owner_name
    user.name rescue nil
  end

  # account owner first name
  def owner_first_name
    user.first_name rescue nil
  end

  # account owner email
  def email
    user.email rescue nil
  end

  # returns default account 
  def self.get_default_acct
    active.where(default_flg: 'Y').first
  end

  def acct_token
    user.acct_token rescue nil
  end
end
