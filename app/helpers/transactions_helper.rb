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

  # get token
  def get_token method
    CREDIT_CARD_API == 'balanced' ? get_card_data(method) : set_token rescue nil
  end

  def set_token
    @user.has_card_account? ? @user.cust_token : nil
  end

  # show help
  def show_help? txn
    !txn.get_fee.blank? rescue nil
  end

  # get cancel path
  def get_cancel_path txn, order
    inv_id = order[:invoice_id] || order['invoice_id']
    if txn.pixi?
      temp_listing_path(id: order['id1'])
    elsif get_btn_method(order) == :put
      decline_invoice_path(id: inv_id, reason: 'Did Not Want (Buy Now)')
    else
      invoice_path(id: inv_id)
    end
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
    txn.pixi? ? txn.temp_listings.first : txn
  end

  # calc amt
  def txn_amt txn
    txn.get_invoice.amount - txn.get_invoice.get_fee(true) rescue 0
  end

  def show_card_details
    render partial: 'shared/credit_card_details' if get_card
  end

  def show_card_image cls
    image_tag('accepted-credit-cards.png', class: cls)
  end

  def show_txn_item item
    render partial: 'shared/txn_order_item', locals: {item: item} unless item.price.blank? 
  end

  def show_purchase_txn_total txn, paid
    render partial: 'shared/purchase_txn_total', locals: {txn: txn, paid: paid} if txn
  end

  def shipping? model
    model.respond_to?(:ship_amt) && !model.ship_amt.nil? && model.ship_amt.to_f > 0
  end

  def show_ship_address f, order, txn
    render partial: 'shared/buyer_ship_info', locals: {f: f, txn: txn} if shipping?(OpenStruct.new(order))
  end

  def change_btn id
    link_to 'Change', '#', id: id, class: 'offset2 btn' if controller_name == 'transactions'
  end

  def show_rating model
    render partial: 'shared/rating_form', locals: { transaction: model } if model.user_id == @user.id
  end

  def get_btn_method order
    listing = Listing.find_by_pixi_id(order[:id1])
    listing && listing.buy_now_flg ? :put : :get
  end

  def show_credit_card f, txn
    render partial: 'shared/credit_card_info', locals: { f: f } if txn.amt > 0.0
  end

  def process_order_row i, order
    render partial: 'shared/order_row', locals: {i: i, order: order} if order['quantity'+i.to_s].to_i > 0
  end

  def render_order_summary txn, order, paid
    render partial: 'shared/order_summary', locals: {txn: txn, order: order, paid: paid} if txn 
  end

  def render_order_tax model
    render partial: 'shared/order_tax', locals: {model: model} if model && model.tax_total.to_f > 0.0
  end

  def render_order_shipping model
    render partial: 'shared/order_shipping', locals: {model: model} if model && model.ship_amt.to_f > 0.0
  end

  def show_discount txn
    render partial: 'shared/show_discount', locals: {txn: txn} if CalcTotal.discount?
  end
end
