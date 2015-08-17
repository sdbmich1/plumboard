module CalcTotal
  # used to calc transaction total

  # process order details
  def self.process_order order
    @amt, @pfee = 0.0, nil

    # process each order item
    (1..order[:cnt].to_i).each do |i| 
      if order['quantity'+i.to_s].to_i > 0 
        calc_price order['price'+i.to_s].to_f, order['quantity'+i.to_s].to_i
      end 
    end 

    # determine discount if any
    set_discount order[:promo_code]
     
    # check for sales tax
    @amt += order[:tax_total].to_f if order[:tax_total]
     
    # check for shipping
    @amt += order[:ship_amt].to_f if order[:ship_amt]

    # return total order amount
    grand_total
  end
  
  # calc total from item details 
  def self.process_details model, ary
    @amt, @pfee = 0.0, nil

    # process each order item
    ary.each do |item| 
      calc_price item.price, item.quantity
    end 

    # determine discount if any
    set_discount model.promo_code
     
    # check for sales tax & shipping
    @amt += model.tax_total.to_f if model.sales_tax
    @amt += model.ship_amt.to_f if model.ship_amt

    # return total amount
    grand_total
  end

  # check for default fees & price
  def self.convenience_fee?
    PIXI_FEE.to_f > 0.0 rescue nil
  end
  
  def self.processing_fee?
    PIXI_PERCENT.to_f > 0.0 rescue nil
  end

  def self.get_price *args
    args[0] ? PIXI_PREMIUM_PRICE.to_f : PIXI_BASE_PRICE.to_f rescue nil
  end
  
  # set discount if any based on promo code
  def self.set_discount promo_code
    @discount = PromoCode.get_code(promo_code, Date.today)
  end
  
  # calculates item price
  def self.calc_price price, amt
    sum = price.to_f * amt.to_i 
    @amt += sum
    sum
  end
   
  def self.get_amt
    @amt
  end
  
  def self.get_discount
    @discount
  end
  
  def self.discount?
    @discount
  end
  
  # calculate discount amount based on discount type used
  def self.calc_discount
    if @discount
      @discount.amountOff ? 0 - @discount.amountOff : @discount.percentOff ? @amt * (@discount.percentOff/-100.0) : 0
    else
      0
    end
  end

  # calculate txn processing fee 
  def self.get_processing_fee *val
    # set amount if empty
    @amt = !val.blank? ? val[0].to_f : @amt || 0.0
    @pfee = (@amt + calc_discount) * (PIXI_PERCENT.to_f / 100) + EXTRA_PROCESSING_FEE.to_f
    @pfee.round(2) 
  end
  
  # Calc PXB adjusted fee from Stripe
  def self.get_adjusted_conv_fee amt, inv_amt
    total = amt - inv_amt - get_processing_fee(amt)
    total.round(2)
  end
  
  # calculate txn convenience fee based on amount and min transaction threshold
  def self.get_convenience_fee *val
    # set amount if empty
    @amt = !val.blank? ? val[0].to_f : @amt || 0.0

    # set appropriate txn percent 
    fee = !val.blank? && !val[1].blank? ? (@amt * PXB_TXN_PERCENT) : (@amt * PIXI_TXN_PERCENT)/2

    # check if fee needs to be applied
    if @amt + calc_discount > 0.0 
      fee > PIXI_FEE.to_f ? fee.to_f.round(2) : PIXI_FEE.to_f.round(2)
    else
      0.0
    end
  end
  
  # calculate txn total
  def self.grand_total
    @amt += get_processing_fee + get_convenience_fee + calc_discount
    @amt.round(2)
  end
  
end
