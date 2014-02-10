class CardAccount < ActiveRecord::Base
  include Payment
  before_create :set_flds, :must_have_token

  attr_accessor :card_number, :card_code
  attr_accessible :card_no, :card_type, :description, :expiration_month, :expiration_year, :status, :token, :user_id,
    :card_number, :card_code, :zip, :default_flg

  belongs_to :user

  validate :must_have_token
  validates :user_id, presence: true
  validates :expiration_month, presence: true
  validates :expiration_year, presence: true
  validates :card_type, presence: true

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
    self.status = 'active'
    self.default_flg = 'Y' unless self.user.has_card_account?
  end

  # add new card
  def save_account 
    card = Payment::create_card self.card_number, self.expiration_month, self.expiration_year, self.card_code, self.zip

    # check for errors
    unless card.blank? 
      return false if self.errors.any?

      # set fields
      self.token, self.card_no, self.expiration_month, self.expiration_year, self.card_type = card.uri, card.last_four, card.expiration_month, 
        card.expiration_year, card.card_type.titleize
    else
      errors.add :base, "Card info is invalid. Please re-enter."
      return false
    end

    # save new account
    save!
  end

  # check if card has expired
  def has_expired?
    expiration_year == Date.today.year ? expiration_month < Date.today.month ? true : false : expiration_year < Date.today.year ? true : false
  end

  # add card 
  def self.add_card model, token=nil
    # get last 4 of card
    card_num = model.card_number[model.card_number.length-4..model.card_number.length] rescue nil

    # check if card exists
    unless card = model.user.card_accounts.where(:card_no => card_num).first
      card = model.user.card_accounts.build card_number: model.card_number, expiration_month: model.exp_month,
	         expiration_year: model.exp_year, card_code: model.cvv, zip: model.zip, card_type: model.payment_type 

      # check if token was already created
      if token
        card.token = token
	card.save!
      else
        card.save_account 
      end
    end
    Rails.logger.info 'Card errors = ' + card.errors.full_messages.to_s
    card.errors.any? ? false : card 
  end
end
