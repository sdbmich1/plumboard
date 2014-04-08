  # Returns the full title on a per-page basis.
  def full_title page_title
    base_title = "Pixiboard"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # format time
  def get_local_time(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y %I:%M%p') rescue nil
  end

  # format short date
  def short_date(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y') rescue nil
  end

  # format short time
  def short_time tm
    tm.utc.getlocal.strftime('%I:%M%p') rescue nil
  end

  # get conv fee message based on user
  def get_conv_fee_msg inv
    if inv
      inv.owner?(@user) ? inv.listing.pixi_post? ? PXPOST_FEE_MSG : SELLER_FEE_MSG : CONV_FEE_MSG
    end
  end

  # get conv fee title
  def get_conv_title inv
    str = inv.owner?(@user) && action_name == 'show' ? 'Less ' : '' rescue ''
    str + 'Convenience Fee'
  end

  # get invoice fee based on user
  def get_invoice_fee inv
    inv.owner?(@user) ? inv.get_fee(true) : inv.get_fee rescue 0
  end

  # get invoice total based on user
  def get_invoice_total inv
    inv.owner?(@user) ? inv.amount : inv.amount + inv.get_fee rescue 0
  end
