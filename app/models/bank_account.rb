class BankAccount < ActiveRecord::Base
  include Payment

  before_create :set_flds, :must_have_token

  attr_accessor :acct_number, :routing_number
  attr_accessible :acct_name, :acct_no, :acct_type, :status, :token, :user_id, :description, :acct_number, :routing_number, :bank_name

  belongs_to :user
  has_many :invoices

  validates :user_id, presence: true
  validates :acct_name, presence: true
#  validate :must_be_numeric
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

  # check if numeric
  def must_be_numeric
    unless acct_number.is_a? Integer
      errors.add(:base, 'Must be a number')
      false
    else
      if (7..15).include? acct_number.to_s.length 
        true
      else
        errors.add(:base, 'Must be between 7 and 15 digits')
        false
      end
    end
  end

  # get active accounts
  def self.active
    where(:status=>'active')
  end

  # set flds
  def set_flds
    self.status = 'active'
  end

  # get account
  def get_account
    Payment::get_bank_account token, self

    # check for errors
    return false if self.errors.any?
  end

  # add new account
  def save_account
    acct = Payment::add_bank_account self

    # check for errors
    if acct 
      return false if self.errors.any?

      # set fields
      self.token, self.acct_no, self.bank_name = acct.uri, acct.account_number, acct.bank_name
    else
      errors.add :base, "Account number, routing number, or account name is invalid."
      return false
    end

    # save new account
    save
  end

  # issue account credit
  def credit_account amt
    result = Payment::credit_account token, amt, self

    # check for errors
    if result 
      self.errors.any? ? false : result 
    else
      errors.add :base, "Error: There was a problem with your Balanced account."
      false
    end
  end

  # delete account
  def delete_account
    result = Payment::delete_account token, self if token

    # remove account
    if result 
      self.errors.any? ? false : self.destroy 
    else
      errors.add :base, "Error: There was a problem with your Balanced account."
      false
    end
  end
end
