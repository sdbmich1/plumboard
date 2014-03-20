module InvoicesHelper

  # set default quantity
  def set_quantity model
    model.quantity || 1
  end

  # set default sales tax
  def get_sales_tax
    @invoice.sales_tax || 0.0
  end

  # check if user has bank account to determine correct routing
  def get_invoice_path
    form = mobile_device? ? 'mobile/invoice_form' : 'shared/invoice_form'
    @user.has_bank_account? ? new_invoice_path : new_bank_account_path(target: form)
  end

  # set page title based on action
  def get_inv_title
    action_name == 'new' ? 'Create Invoice' : 'Edit Invoice'
  end

  # toggle inv payer or payee based on flg
  def set_inv_model inv, buyFlg
    buyFlg ? inv.buyer : inv.seller
  end

  # toggle inv payer or payee based on action name
  def get_invoice_name inv
    action_name == 'received' ? inv.seller_name : inv.buyer_name
  end

  # check if selected pixi is wanted
  def has_wanted_pixi? pid
    @wantFlg ||= Listing.find_by_pixi_id(pid).is_wanted? rescue nil
  end

  # set btn class
  def pay_btn_cls
    controller_name == 'posts' ? 'btn btn-medium btn-primary' : 'btn btn-large btn-primary'
  end

  # set buyer name if exists
  def load_buyer
    @invoice.buyer_name rescue ''
  end

  # get invoice fee based on user
  def get_invoice_fee
    @invoice.owner?(@user) ? @invoice.get_fee(true) : @invoice.get_fee
  end

  # get conv fee message based on user
  def get_conv_fee_msg
    @invoice.owner?(@user) ? @invoice.listing.pixi_post? ? PXPOST_FEE_MSG : SELLER_FEE_MSG : CONV_FEE_MSG
  end

  # get invoice total based on user
  def get_invoice_total inv
    inv.owner?(@user) ? inv.amount : inv.amount + inv.get_fee
  end

  # get conv fee title
  def get_conv_title
    str = @invoice.owner?(@user) && action_name == 'show' ? 'Less ' : ''
    str + 'Convenience Fee'
  end
end
