class TransactionObserver < ActiveRecord::Observer
  observe Transaction
  include PointManager, AddressManager

  def after_create txn
    unless txn.pixi?
      
      # update points
      PointManager::add_points txn.user, 'inv' 
      
      # notify seller
      send_post txn

      # update buyer address info
      update_contact_info txn
    end

    # send receipt upon approval
    UserMailer.delay.send_transaction_receipt(txn) if txn.approved?
  end

  def after_update txn
    # update buyer address info
    update_contact_info txn

    # send receipt upon approval
    UserMailer.delay.send_transaction_receipt(txn) if txn.approved?
  end

  # notify seller          
  def send_post txn
    Post.pay_invoice txn
  end

  # update user contact info if no address is already saved
  def update_contact_info txn
    AddressManager::set_user_address txn.user, txn
  end
end
