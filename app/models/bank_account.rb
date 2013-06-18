class BankAccount < ActiveRecord::Base
  include Payment

  before_create :set_flds

  attr_accessor :acct_number, :routing_number
  attr_accessible :acct_name, :acct_no, :acct_type, :status, :token, :user_id, :description, :acct_number, :routing_number

  belongs_to :user
  has_many :invoices

  validates :user_id, presence: true
  validates :acct_name, presence: true
#  validate :must_be_numeric

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
    return false if self.errors.any?

    # set fields
    self.token, self.acct_no = acct.uri, acct.account_number

    # save new account
    save!
  end

  # issue account credit
  def credit_account amt
    Payment::credit_account token, amt, self

    # check for errors
    return false if self.errors.any?
  end

  # delete account
  def delete_account
    Payment::delete_account token, self if token

    # check for errors
    return false if self.errors.any?
  end
end
