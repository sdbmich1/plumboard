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
  
  def get_fname txn, fname, flg
    flg ? fname : txn.send(fname)
  end
  
  def get_promo_code
    @order ? @order[:promo_code] ? @order[:promo_code] : nil : nil
  end

  # get price
  def get_price
    CalcTotal::get_price @listing.premium?
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
  def get_page_title *args
    @transaction.pixi? ? 'Submit Your Pixi' : 'Pay Invoice'
  end

  # return page header based on transaction type
  def get_header
    @transaction.pixi? ? "Step 3 of 3: Submit Your Pixi" : "PixiPay | Pay Invoice"
  end

  # return page header based on transaction type
  def get_page_header
    @transaction.pixi? ? 'Pixi' : 'Purchase'
  end

  # set cancel message
  def cancel_msg
    'Are you sure? All your changes will be lost.'
  end

  # set prev btn based on txn type
  def set_prev_btn
    @transaction.pixi? ? @listing : @invoice
  end

  # set details based on transaction type
  def txn_details txn
    txn.pixi? ? txn.description : "#{txn.description} from #{txn.seller_name}" 
  end

  # set partial based on txn type
  def set_txn_partial
    path = mobile_device? ? 'mobile' : 'shared'
    pname = path + (@transaction.pixi? ? '/order_complete' : '/purchase_complete')
  end
end
