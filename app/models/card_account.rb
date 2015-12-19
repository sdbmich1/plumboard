class CardAccount < ActiveRecord::Base
  before_create :set_flds, :must_have_token

  attr_accessor :card_number, :card_code
  attr_accessible :card_no, :card_type, :description, :expiration_month, :expiration_year, :status, :token, :user_id,
    :card_number, :card_code, :zip, :default_flg, :card_token

  belongs_to :user, counter_cache: 'active_cards_count'

  validate :must_have_token
  validates :user_id, presence: true
  validates :expiration_month, presence: true
  validates :expiration_year, presence: true
  validates :card_type, presence: true
  validates :zip, presence: true, length: {is: 5}

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
    CardProcessor.new(self).save_card
  end

  # check if card has expired
  def has_expired?
    expiration_year == Date.today.year ? expiration_month < Date.today.month ? true : false : expiration_year < Date.today.year ? true : false
  end

  # add card 
  def self.add_card model, token=nil
    CardProcessor.new(self).add_card(model, token)
  end

  # delete card from API
  def delete_card
    CardProcessor.new(self).delete_card
  end

  # remove saved cards
  def self.remove_cards model
    CardProcessor.new(self).remove_cards(model.id)
  end

  # process messages
  def process_error e
    self.errors.add :base, "Card declined or invalid. Please re-submit." 
    Rails.logger.info "PXB Card failed: #{e.message}" 
    self
  end

  # returns default account 
  def self.get_default_acct
    active.where(default_flg: 'Y').first
  end

  def email
    user.email rescue nil
  end

  def buyer_name
    user.name rescue nil
  end

  def cust_token
    user.cust_token rescue nil
  end

  # get list of cards or card holders based on adminFlg
  def self.card_list model, aFlg=false
    CardProcessor.new(self).card_list(model, aFlg)
  end

  def self.inc_list
    includes(:user => [:user_type, :pictures, :preferences])
  end

  rescue => ex
    process_error ex
end
