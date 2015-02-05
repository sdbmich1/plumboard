module TransactionsHelper

  # set default quantity
  def set_qty fldname
    if @order
      @order[fldname] ? @order[fldname].to_i : 0
    else
      0
    end
  end
  
  # discount display text
  def get_descr
    'A ' + get_discount + ' discount will be applied at checkout.' if @discount
  end
  
  # display discount % if any
  def get_discount
    if @discount
      @discount.amountOff ? '$'+ @discount.amountOff.to_s : @discount.percentOff.to_s + '%'
    else
      'N/A'
    end
  end
  
  # return fname
  def get_fname txn, fname, flg
    flg ? fname : txn.send(fname)
  end
  
  # return promo code if found
  def get_promo_code order
    order ? order[:promo_code] ? order[:promo_code] : nil : nil
  end

  # get price
  def get_price listing
    CalcTotal::get_price listing.premium?
  end
  
  # set display text based on paid status
  def show_title paid
    paid ? 'Total Paid' : 'Total Due'
  end
  
  # set confirmation message based on txn amount
  def confirm_msg
    msg = CalcTotal::get_amt > 0 ? "Your credit card " : "Your order "
    msg += "will be processed.  Would you like to proceed?"
  end

  # reset time display format
  def get_local_time(tm)
    tm.strftime('%m/%d/%Y %I:%M%p')
  end

  # return page title based on transaction type
  def get_page_title txn
    txn && txn.pixi? ? 'Submit Your Pixi' : 'PixiPay'
  end

  # return page header based on transaction type
  def get_header
    @transaction.pixi? ? "Step 3 of 3: Submit Your Pixi" : "PixiPay"
  end

  # return page header based on transaction type
  def get_page_header txn
    txn.pixi? ? 'Pixi' : 'Purchase'
  end

  # set cancel message
  def cancel_msg
    'Are you sure? All your changes will be lost.'
  end

  # set prev btn based on txn type
  def set_prev_btn txn, inv
    txn.pixi? ? inv.listings.first : inv
  end

  # set partial based on txn type
  def set_txn_partial txn
    path = mobile_device? ? 'mobile' : 'shared'
    pname = path + (txn.pixi? ? '/order_complete' : '/purchase_complete')
  end

  # get card element for user if exists
  def get_card_data method
    get_card.send(method) rescue nil
  end

  # get valid card for user
  def get_card
    @card ||= @user.get_valid_card
  end

  # show help
  def show_help? txn
    !txn.get_fee.blank? rescue nil
  end

  # get cancel path
  def get_cancel_path txn, order
    txn.pixi? ? temp_listing_path(id: order['id1']) : invoice_path(id: order[:invoice_id])
  end

  # get related invoice
  def get_invoice model
    Invoice.find(model.invoice_id) rescue model
  end

  # get related item
  def get_item pid
    Listing.find_by_pixi_id(pid) rescue nil
  end

  # set model based on transaction type
  def set_model txn
    txn.pixi? ? txn.get_invoice_listing : txn
  end
end
