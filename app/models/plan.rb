class Plan < ActiveRecord::Base
  attr_accessible :name, :interval, :price, :status, :stripe_id, :trial_days

  has_many :subscriptions

  def self.add_plan name, price, interval, trial_days
    plan = Plan.new
    plan.name, plan.price, plan.interval, plan.trial_days = name, price, interval, trial_days
    stripe_plan = Payment.add_plan(plan)
    plan.stripe_id = stripe_plan.id
    plan.status = 'active'
    plan.save
  end

  def remove_plan
    plan = Payment.remove_plan(self)
    Rails.logger.info("self.errors: #{self.errors.to_a}")
    return false if self.errors.any?
    self.update_attribute(:status, 'removed') if plan
  end

  def update_plan name
    plan = Payment.update_plan(self, name)
    return false if self.errors.any?
    self.name = name
    self.save
  end

  def self.active
    where(status: 'active')
  end

  def process_error e
    self.errors.add :base, 'Plan data error. Please resubmit.'
    Rails.logger.info("PXB Plan Failed: #{e.message}")
    self
  end
end
