class Subscription < ActiveRecord::Base
  attr_accessible :user_id, :plan_id, :stripe_id, :card_account_id

  belongs_to :plan
  belongs_to :user
  belongs_to :card_account

  def self.add_subscription pid, uid, acct_id
    sub = Subscription.new
    sub.plan_id, sub.user_id, sub.card_account_id, sub.status = pid, uid, acct_id, 'active'
    stripe_sub = Payment.add_subscription(sub)
    return false if sub.errors.any?
    sub.stripe_id = stripe_sub.id
    sub.save
  end

  def cancel_subscription
    sub = Payment.cancel_subscription(self)
    return false if self.errors.any?
    self.update_attribute(:status, 'cancelled')
  end

  def update_subscription plan
    sub = Payment.update_subscription(self, plan.stripe_id)
    return false if self.errors.any?
    self.update_attribute(:plan_id, plan.id)
  end

  def process_error e
    self.errors.add :base, 'Subscription data error. Please resubmit.'
    Rails.logger.info("PXB Subscription Failed: #{e.message}")
    self
  end
end
