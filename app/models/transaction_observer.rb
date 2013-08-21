class TransactionObserver < ActiveRecord::Observer
  observe Transaction
  include PointManager

  def after_create txn
    unless txn.pixi?
      
      # update points
      PointManager::add_points txn.user, 'inv' 
      
      # notify seller
      send_post txn
    end

    # send receipt upon approval
    UserMailer.delay.send_transaction_receipt(txn) if txn.approved?
  end

  # send receipt upon approval
  def after_update txn
    UserMailer.delay.send_transaction_receipt(txn) if txn.approved?
  end

  # notify seller          
  def send_post txn
    Post.pay_invoice txn
  end
end
