class TransactionObserver < ActiveRecord::Observer
  observe Transaction
  include PointManager

  # update points
  def after_create txn
    PointManager::add_points txn.user, 'inv' unless txn.pixi?
    send_post txn
  end

  # send receipt upon approval
  def after_update txn
    UserMailer.send_transaction_receipt(txn).deliver if txn.approved?
  end

  private

  # notify seller          
  def send_post txn
    Post.pay_invoice txn
  end
end
