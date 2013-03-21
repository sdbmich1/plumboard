class TransactionObserver < ActiveRecord::Observer
  observe Transaction

  # send receipt upon approval
  def after_update txn
    UserMailer.send_transaction_receipt(txn).deliver if txn.status == 'approved'
  end
end
