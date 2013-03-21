module TransactionsHelper

  def set_qty fldname
    if @order
      @order[fldname] ? @order[fldname].to_i : 0
    else
      0
    end
  end
  
  def get_descr
    'A ' + get_discount + ' discount will be applied at checkout.' if @discount
  end
  
  def get_discount
    if @discount
      @discount.amountOff ? '$'+ @discount.amountOff.to_s : @discount.percentOff.to_s + '%'
    else
      'N/A'
    end
  end
  
  def get_ary
    (0..30).inject([]){|x,y| x << y}
  end
  
  def get_fname txn, fname, flg
    flg ? fname : txn.send(fname)
  end
  
  def get_promo_code
    @order ? @order[:promo_code] ? @order[:promo_code] : nil : nil
  end

  def get_price
    PIXI_BASE_PRICE.to_f rescue nil
  end
  
  def show_title paid
    paid ? 'Total Paid' : 'Total Due'
  end
  
  def confirm_msg
    if @total > 0
      "Your credit card will be processed.  Would you like to proceed?"
    else
      "Your order will be processed.  Would you like to proceed?"
    end
  end
end
