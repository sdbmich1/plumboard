class Subscription < ActiveRecord::Base
  attr_accessible :user_id, :plan_id, :stripe_id, :card_account_id,
    :contact_attributes, :card_account_attributes

  belongs_to :plan
  belongs_to :user
  belongs_to :card_account
  has_one :contact, as: :contactable

  validates :user_id, presence: true
  validates :plan_id, presence: true
  validates :card_account_id, presence: true

  accepts_nested_attributes_for :contact, allow_destroy: true
  accepts_nested_attributes_for :card_account, allow_destroy: true

  def add_subscription
    sub = Payment.add_subscription(self)
    return false if self.errors.any?
    self.stripe_id = sub.id
    self.save
  end

  def cancel_subscription
    sub = Payment.cancel_subscription(self)
    return false if self.errors.any?
    self.update_attribute(:status, 'cancelled')
  end

  def update_subscription params
    return false unless params && params[:subscription] && (plan = Plan.find(params[:subscription][:plan_id]))
    sub = Payment.update_subscription(self, plan.stripe_id)
    return false if self.errors.any?
    self.update_attribute(:plan_id, plan.id)
    self.update_attribute(:user_id, params[:subscription][:user_id])
    self.contact.update_attributes(params[:subscription][:contact_attributes])
  end

  def self.load_new plan_id, user
    sub = self.new(plan_id: plan_id, user_id: user.id)
    sub.load_data(user)
  end

  def load_data user
    self.create_contact unless self.contact
    AddressManager::synch_address(self.contact, user.contacts.first, false) if user.has_address?
    self
  end

  def plan_name
    plan.try(:name)
  end

  def plan_price
    plan.try(:price) || 0.0
  end

  def add_card_account params
    if params[:subscription][:card_account_id].blank?
      card = self.build_card_account(params[:subscription][:card_account_attributes])
      card.user_id = params[:subscription][:user_id]
      card.expiration_month = params[:card_month]
      card.expiration_year = params[:card_year]
      card.zip = params[:subscription][:contact_attributes][:zip]
      card.save_account
    else
      self.card_account_id = params[:subscription][:card_account_id].to_i
    end
    self
  end

  def self.sub_list user, adminFlg
    adminFlg ? includes(:user, :plan, :card_account) : user.subscriptions.includes(:user, :plan, :card_account)
  end

  def process_error e
    self.errors.add :base, 'Subscription data error. Please resubmit.'
    Rails.logger.info("PXB Subscription Failed: #{e.message}")
    self
  end
end
