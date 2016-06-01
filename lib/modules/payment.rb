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
    else
      StripePayment::get_bank_account(token, acct)
    end
  end

  # add bank account
  def self.add_bank_account acct, ip
    if PAYMENT_API == 'balanced' 
      BalancedPayment::add_bank_account(acct)
    else
      StripePayment::add_bank_account(acct, ip)
    end
  end

  # credit bank account
  def self.credit_account token, amt, acct
    if PAYMENT_API == 'balanced' 
      BalancedPayment::credit_account(token, amt, acct)
    else
      StripePayment::credit_account(token, amt, acct)
    end
  end

  # delete bank account
  def self.delete_account token, acct
    case CREDIT_CARD_API
    when 'balanced' 
      BalancedPayment::delete_account(token, acct)
    when 'stripe' 
      result = StripePayment::delete_account(token, acct)
    end
  end

  # create credit card
  def self.create_card acct
    case CREDIT_CARD_API
    when 'balanced' 
      result = BalancedPayment::create_card acct
    when 'stripe' 
      result = StripePayment::create_card acct
    end
  end

  # assign credit card
  def self.assign_card card, acct, token
    case CREDIT_CARD_API
    when 'balanced' 
      result = BalancedPayment::assign_card card, acct, token
    when 'stripe' 
      result = StripePayment::assign_card card, acct, token
    end
  end

  # charge credit card
  def self.charge_card txn
    case CREDIT_CARD_API
    when 'balanced' 
      result = BalancedPayment::charge_card txn
    when 'stripe'
      result = StripePayment::charge_card txn
    end
  end

  # delete credit card
  def self.delete_card token, acct
    case CREDIT_CARD_API
    when 'balanced' 
      result = BalancedPayment::delete_card token, acct
    when 'stripe'
      result = StripePayment::delete_card token, acct
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

  # add transaction
  def self.add_transaction model, fee, result
    case CREDIT_CARD_API
    when 'balanced' 
      PixiPayment.add_transaction(model, fee, result.uri, result.id) rescue nil
    when 'stripe'
      PixiPayment.add_transaction(model, fee, result.id, result.id) rescue nil
    end
  end

  def self.credit_seller_account model
    case CREDIT_CARD_API
    when 'balanced' 
      BalancedPayment.credit_seller_account(model) rescue nil
    when 'stripe'
      StripePayment.credit_seller_account(model) rescue nil
    end
  end

  def self.add_plan model
    StripePayment.add_plan model
  end

  def self.update_plan model, name
    StripePayment.update_plan model, name
  end

  def self.get_plan model
    StripePayment.get_plan model
  end

  def self.remove_plan model
    StripePayment.remove_plan model
  end

  def self.add_subscription model
    StripePayment.add_subscription model
  end

  def self.get_subscription model, customer
    StripePayment.get_subscription model, customer
  end

  def self.cancel_subscription model
    StripePayment.cancel_subscription model
  end

  def self.update_subscription model, plan_id
    StripePayment.update_subscription model, plan_id
  end
end
