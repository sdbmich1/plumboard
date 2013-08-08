class TransactionObserver < ActiveRecord::Observer
  observe Transaction
  include PointManager

  # update points
  def after_create txn
    unless txn.pixi?
      PointManager::add_points txn.user, 'inv' 
      send_post txn
    end
  end

  # send receipt upon approval
  def after_update txn
    UserMailer.delay.send_transaction_receipt(txn) if txn.approved?
  end

  private

  # notify seller          
  def send_post txn
    Post.pay_invoice txn
  end
end
