class TransactionProcessor
  include CalcTotal, AddressManager, Payment

  def initialize txn
    @txn = txn
  end

  # load initial data
  def load_data usr, order
    load_init_fees order
    load_inv_info order
    load_buyer_info usr
    @txn
  end

  def load_init_fees order
    @txn.amt = CalcTotal::process_order order
    @txn.processing_fee = CalcTotal::get_processing_fee order[:inv_total]
    @txn.convenience_fee = CalcTotal::get_convenience_fee order[:inv_total]
    @txn.transaction_type = order[:transaction_type]
  end

  # get invoice data
  def load_inv_info order
    if inv = Invoice.where(id: order[:invoice_id]).first
      @txn.seller_token = inv.seller.acct_token
      @txn.seller_inv_amt = inv.seller_amount
    end
  end

  def load_buyer_info usr
    @txn.user_id = usr.id
    @txn.first_name, @txn.last_name, @txn.email = usr.first_name, usr.last_name, usr.email
    @txn = AddressManager::synch_address @txn, usr.contacts[0], false if usr.has_address?
  end

  # add each transaction item
  def add_details item, qty, val
    if item && val
      item_detail = @txn.transaction_details.build rescue nil
      item_detail.item_name, item_detail.quantity, item_detail.price = item, qty, val if item_detail
    end
    item_detail
  end

  # add transaction details      
  def process_details order
    (1..order[:cnt].to_i).each do |i| 
      if order['quantity'+i.to_s].to_i > 0 
        add_details order['item'+i.to_s], order['quantity'+i.to_s], order['price'+i.to_s].to_f 
      end 
    end 
  end

  # check for token
  def has_token?
    if @txn.token.blank?
      @txn.errors.add :base, "Card info is missing or invalid. Please re-enter."
      false
    else
      if @txn.card_number.blank?  
        @txn.user.has_card_account? ? true : false
      else
        @txn.token
      end
    end
  end

  # store results in db
  def set_fields result
    @txn.confirmation_no = result.id 
    if CREDIT_CARD_API == 'balanced'
      @txn.payment_type, @txn.credit_card_no, @txn.debit_token = result.source.card_type, result.source.last_four, result.uri
    else
      @txn.payment_type, @txn.credit_card_no, @txn.debit_token = result.source.brand, result.source.last4, result.source.id
    end
  end
  
  # process transaction
  def process_data
    result = Payment::charge_card(@txn) if @txn.amt > 0.0
    return false if @txn.errors.any?

    # check result - update confirmation # if nil (free transactions) use timestamp instead
    if result
      set_fields result
    else
      if @txn.amt > 0.0
	return false
      else
        @txn.confirmation_no = Time.now.to_i.to_s   
      end
    end  

    # set status
    @txn.status = 'approved'
    @txn.save!  
  end
 
  # save transaction data
  def save_data order
    process_details order

    # submit payment or order based on transaction type
    if @txn.pixi? 
      @txn.status = 'pending' # set status
      @txn.save!  

      # submit order
      unless @txn.errors.any?
        Listing.where(pixi_id: order['id1']).first.submit_order(@txn.id) rescue false
      end
    else
      process_card order
    end
  end

  # process credit card
  def process_card order
    if has_token? 
      if process_data
        inv = Invoice.find(order["invoice_id"])
        inv.submit_payment(@txn.id) if inv
      else
        @txn.errors.add :base, "Transaction processing failed. Please re-enter."
        false
      end
    else
      false
    end
  end
end
