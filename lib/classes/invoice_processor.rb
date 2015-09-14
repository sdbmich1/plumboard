class InvoiceProcessor
  include CalcTotal

  def initialize inv
    @invoice = inv
  end

  # set flds
  def set_flds
    @invoice.status = 'unpaid' if @invoice.status.nil?
    @invoice.inv_date = Time.now if @invoice.inv_date.blank?
    @invoice.bank_account_id = @invoice.seller.bank_accounts.get_default_acct.id rescue nil if @invoice.seller.has_bank_account?
  end

  # validate picture exists
  def must_have_pixis
    if !any_pixi?
      @invoice.errors.add(:base, 'Must have a pixi')
      false
    else
      true
    end
  end

  # check for a pixi
  def any_pixi?
    @invoice.invoice_details.detect { |x| x && !x.pixi_id.nil? }
  end

  # load new invoice with most recent pixi data
  def load_new usr, buyer_id, pixi_id
    if usr && usr.has_pixis?
      pixi = usr.active_listings.first if usr.active_listings.size == 1
      inv = usr.invoices.build buyer_id: buyer_id
      load_inv_details inv, pixi, buyer_id, pixi_id
      inv
    end
  end

  def load_inv_details inv, pixi, buyer_id, pixi_id
    det = inv.invoice_details.build
    det.pixi_id = !pixi_id.blank? ? pixi_id : !pixi.blank? ? pixi.id : nil rescue nil
    det.quantity = det.listing.active_pixi_wants.where(user_id: buyer_id).first.quantity rescue 1
    det.price = det.listing.price || 0 if det.listing
    det.amt_left = det.listing.amt_left rescue 1
    det.subtotal = inv.amount = det.listing.price * det.quantity if det.listing rescue 0
  end

  # submit payment request for review
  def submit_payment val
    if val
      @invoice.transaction_id, @invoice.status = val, 'paid' 
      @invoice.save!
    else
      false
    end
  end

  # credit account & process payment
  def credit_account
    if @invoice.amount
      result = @invoice.bank_account.credit_account(seller_amount) rescue false
    else
      false
    end
  end

  def get_fee sellerFlg, fee
    if @invoice.amount
      if sellerFlg
        @invoice.invoice_details.each do |x|
          fee += CalcTotal::get_convenience_fee(x.subtotal, x.listing.pixan_id) unless x.listing.pixan_id.blank?
        end
        fee += CalcTotal::get_convenience_fee(@invoice.amount, nil, true) if fee == 0.0 && @invoice.seller.is_business?
      end
      fee += CalcTotal::get_convenience_fee(@invoice.amount) if fee == 0.0
      fee += CalcTotal::get_processing_fee(@invoice.amount) unless sellerFlg
      fee.round(2)
    else
      0.0
    end
  end

  # get txn processing fee
  def get_processing_fee
    @invoice.amount ? CalcTotal::get_processing_fee(@invoice.amount).round(2) : 0.0
  end

  # get txn convenience fee
  def get_convenience_fee
    @invoice.amount ? CalcTotal::get_convenience_fee(@invoice.amount).round(2) : 0.0
  end

  # load assn details
  def load_details
    Invoice.find_each do |inv|
      inv.invoice_details.create pixi_id: inv.pixi_id, quantity: inv.quantity, price: inv.price, subtotal: inv.subtotal
    end
  end

  # marked as closed any other invoice associated with this pixi
  def mark_as_closed 
    if @invoice.paid?
      listings.find_each do |listing|
        inv_list = Invoice.where(status: 'unpaid').joins(:invoice_details).where("`invoice_details`.`pixi_id` = ?", listing.pixi_id).readonly(false)
        inv_list.find_each do |inv|
          inv.update_attribute(:status, 'closed') if inv.pixi_count == 1 && inv.id != @invoice.id && inv.buyer_id == @invoice.buyer_id
        end
      end
    end
  end

  def decline_msg
    case @invoice.decline_reason
      when "No Longer Interested"; "I am no longer interested in this pixi.  Thank you."
      when "Incorrect Pixi"; "You have invoiced me for the wrong pixi.  Thank you."
      when "Incorrect Price"; "This was not the price that I was expecting for this pixi. Thank you."
      when "Did Not Want"; "You have mistakenly invoiced me for this pixi.  Thank you."
    end
  end

  # get seller amount minus fees
  def seller_amount
    val = @invoice.seller.is_business? ? true : nil
    amt = @invoice.amount - CalcTotal::get_convenience_fee(@invoice.amount, pixan_id, val) rescue @invoice.amount
    amt.round(2) rescue 0.0
  end

  # get pixan id
  def pixan_id
    x = @invoice.listings.detect {|x| !x.pixan_id.blank? } rescue nil
    x.pixan_id if x
  end
end
