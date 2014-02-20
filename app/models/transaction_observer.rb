class TransactionObserver < ActiveRecord::Observer
  observe Transaction
  include PointManager

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

  # send receipt upon approval
  def after_update txn
    UserMailer.delay.send_transaction_receipt(txn) if txn.approved?
  end

  # notify seller          
  def send_post txn
    Post.pay_invoice txn
  end

  # update user contact info if no address is already saved
  def update_contact_info txn
    usr = txn.user
      
    # load user contact info
    unless usr.has_address?
      # if user email is nil
      usr.email = txn.email if usr.email.blank?
      @addr = usr.contacts.build

      @addr.address, @addr.address2 = txn.address, txn.address2
      @addr.city, @addr.state = txn.city, txn.state
      @addr.zip, @addr.home_phone, @addr.country = txn.zip, txn.home_phone, txn.country 
      usr.save
    end
  end
end
