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
  def has_wanted_pixi? inv
    inv.listing.is_wanted? rescue nil
  end
end
