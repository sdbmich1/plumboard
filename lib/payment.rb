module Payment
  ########################################################################################
  #
  # Used to process credit card and banking interactions with 3rd party APIs
  #
  ########################################################################################

  # get account
  def self.get_bank_account token, acct
    if PAYMENT_API == 'balanced' 
      BalancedPayment::get_bank_account(token, acct)
    end
  end

  # add bank account
  def self.add_bank_account acct
    if PAYMENT_API == 'balanced' 
      BalancedPayment::add_bank_account(acct)
    end
  end

  # credit bank account
  def self.credit_account token, amt, acct
    if PAYMENT_API == 'balanced' 
      BalancedPayment::credit_account(token, amt, acct)
    end
  end

  # delete bank account
  def self.delete_account token, acct
    if PAYMENT_API == 'balanced' 
      BalancedPayment::delete_account(token, acct)
    end
  end

  # create credit card
  def self.create_card card_no, exp_month, exp_yr, cvv, zip
    case CREDIT_CARD_API
    when 'balanced' 
      result = BalancedPayment::create_card card_no, exp_month, exp_yr, cvv, zip
    end
  end

  # charge credit card
  def self.charge_card token, amt, descr, txn
    case CREDIT_CARD_API
    when 'balanced' 
      result = BalancedPayment::charge_card token, amt, descr, txn
    when 'stripe'
      result = StripePayment::charge_card token, amt, descr, txn
    end
  end

  # process credit card result
  def self.process_result result, txn
    case CREDIT_CARD_API
    when 'balanced' 
      result = BalancedPayment::process_result result, txn
    when 'stripe'
      result = StripePayment::process_result result, txn
    end
  end
end
