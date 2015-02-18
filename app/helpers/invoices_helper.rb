module InvoicesHelper

  # add new details for invoice
  def setup_inv(invoice)
    invoice.invoice_details 
    return invoice
  end

  # set default quantity
  def set_quantity model
    model.quantity || 1
  end

  # set default sales tax
  def get_sales_tax invoice
    invoice.sales_tax || 0.0
  end

  # check if user has bank account to determine correct routing
  def get_invoice_path uid=nil, pid=nil
    form = mobile_device? ? 'mobile/invoice_form' : 'shared/invoice_form'
    @user.has_bank_account? ? new_invoice_path(buyer_id: uid, pixi_id: pid) : new_bank_account_path(target: form)
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
    controller_name == 'posts' ? 'btn btn-medium btn-primary' : 'btn btn-large btn-primary submit-btn'
  end

  # set buyer name if exists
  def load_buyer invoice
    invoice.buyer_name rescue ''
  end

  # get invoice fee based on user
  def get_invoice_fee inv
    inv.owner?(@user) ? inv.get_fee(true) : inv.get_fee rescue 0
  end

  # switch column title based on action
  def get_column_title
    action_name == 'received' ? 'From' : 'Bill To'
  end

  # switch display name based on action
  def display_name inv
    action_name == 'received' ? inv.seller_name : inv.buyer_name 
  end

  # get invoice total based on user
  def get_invoice_total inv
    inv.owner?(@user) ? inv.amount : inv.amount + inv.get_fee rescue 0
  end

  # get conv fee message based on user
  def get_conv_fee_msg inv
    if inv
      inv.owner?(@user) ? inv.pixi_post? ? PXPOST_FEE_MSG : SELLER_FEE_MSG : CONV_FEE_MSG
    end
  end

  # get conv fee title
  def get_conv_title inv
    str = inv.owner?(@user) && action_name == 'show' ? 'Less ' : '' rescue ''
    str + 'Convenience Fee'
  end

  # build dynamic cache key for invoice page
  def cache_key_for_invoice(invoice)
    "invoice-#{invoice.id}-user-#{@user.id}-time-{Time.now}"
  end

  # check for multiples
  def multiple_pixis?
    @user.pixi_count > 1
  end

  # check if user's invoice is unpaid
  def my_unpaid_invoice? invoice
    invoice.owner?(@user) && invoice.unpaid? 
  end
 
  # set inv title
  def inv_title inv
    str = inv.pixi_count > 1 ? ' +' : ''
    inv.pixi_title + str
  end
end
