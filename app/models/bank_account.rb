class BankAccount < ActiveRecord::Base
  include Payment

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
    if self.token.blank?
      errors.add(:base, 'Must have a token')
      false
    else
      true
    end
  end

  # get active accounts
  def self.active
    where(:status=>'active')
  end

  # set flds
  def set_flds
    self.status, self.default_flg = 'active', 'Y' unless self.user.has_bank_account?
  end

  # get account
  def get_account
    Payment::get_bank_account token, self

    # check for errors
    return false if self.errors.any?
  end

  # add new account
  def save_account ip	
    acct = Payment::add_bank_account self, ip

    # check for errors
    if acct 
      return false if self.errors.any?
    else
      errors.add :base, "Account number, routing number, or account name is invalid."
      return false
    end

    # save new account
    save!
  end

  # issue account credit
  def credit_account amt
    result = Payment::credit_account token, amt, self

    # check for errors
    if result 
      self.errors.any? ? false : result 
    else
      errors.add :base, "Error: There was a problem with your bank account."
      false
    end
  end

  # delete account
  def delete_account
    result = Payment::delete_account token, self if token

    # remove account
    if result 
      self.errors.any? ? false : self.update_attribute(:status, 'removed') 
    else
      errors.add :base, "Error: There was a problem with your bank account."
      false
    end
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
    where(default_flg: 'Y').first
  end

  def acct_token
    user.acct_token rescue nil
  end
end
