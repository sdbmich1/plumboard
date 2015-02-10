module BalancedPayment

  # configure settings
  def self.included base
    initialize
  end

  def self.initialize mpFlg=true
    # configure account
    Balanced.configure BALANCED_API_KEY

    # set marketplace
    @marketplace = Balanced::Marketplace.my_marketplace if mpFlg
  end

  # add bank account
  def self.add_bank_account acct
    initialize false

    # get buyer token
    uri = acct.user.acct_token

    # determine seller
    seller = get_customer uri, acct, true

    @bank_account = Balanced::BankAccount.new(
      account_number: 	acct.acct_number, 
      routing_number: 	acct.routing_number,
      name: 		acct.acct_name,
      type: 		acct.acct_type).save

    # add account to customer record
    seller.add_bank_account(@bank_account.uri)

    return @bank_account

    rescue => ex
      process_error acct, ex
  end

  # add card account
  def self.add_card_account customer, model, token

    # add card to db
    Rails.logger.info "PXB customer add card: #{token}"
    CardAccount.add_card(model, token)

    rescue => ex
      process_error model, ex
  end

  # get account
  def self.get_bank_account token, acct

    @acct ||= acct
    @bank_account ||= Balanced::BankAccount.find token

    rescue => ex
      process_error acct, ex
  end

  # credit bank account
  def self.credit_account token, amt, acct
    initialize

    # get acct 
    bank_acct = get_bank_account(token, acct)

    # credit account
    result = bank_acct.credit(amount: (amt * 100).to_i, appears_on_statement_as: 'pixiboard.com') if amt > 0.0

    rescue => ex
      process_error acct, ex
  end

  # delete bank account
  def self.delete_account token, acct
    initialize false

    # find existing account
    ba = get_bank_account(token, acct)
    ba.unstore if ba

    rescue => ex
      process_error acct, ex
  end

  # create card account
  def self.create_card card_no, exp_month, exp_yr, cvv, zip
    initialize

    card = Balanced::Card.new(
      card_number: card_no, 
      expiration_month: exp_month,
      expiration_year: exp_yr, 
      security_code: cvv, 
      postal_code: zip).save
  end

  # assign card account to customer
  def self.assign_card cust_token, card_token
    customer = Balanced::Customer.find cust_token
    response = customer.add_card card_token
  end

  # charge card account
  def self.charge_card token, amt, descr, txn 
    initialize

    # get buyer token
    uri = txn.user.acct_token

    # define meta data for tracking
    meta = { 'address'=> txn.address, 'city'=> txn.city, 'state'=> txn.state, 'zip'=> txn.zip, 'pixi_id'=> txn.pixi_id }

    # determine buyer
    buyer = get_customer uri, txn, false, token

    # charge card
    result = buyer.debit(amount: (amt * 100).to_i.to_s, appears_on_statement_as: 'pixiboard.com', meta: meta, source_uri: 
      card_token(txn, token, txn.card_number.blank?))

    rescue => ex
      process_error txn, ex
  end

  def self.card_token txn, token, selFlg=true
    selFlg ? txn.user.card_accounts.get_default_acct.token : token
  end

  # removes card
  def self.delete_card token, acct
    initialize false

    # unstore card 
    card = Balanced::Card.find token
    card.unstore if card

    rescue => ex
      process_error acct, ex
  end

  # get customer 
  def self.get_customer uri, txn, slrFlg=false, token=''

    # check if uri exists else create token
    unless uri.blank?
      customer = Balanced::Customer.find uri rescue nil
      customer = set_token txn, slrFlg, token unless customer
    else
      customer = set_token txn, slrFlg, token
    end

    # check if buyer has just a seller account
    unless slrFlg
      if !txn.card_number.blank?
        add_card_account(customer, txn, token) 
      elsif !txn.user.has_card_account?
        add_card_account(customer, txn, token) 
      end
    end
    customer
  end

  # set buyer uri
  def self.set_token model, slrFlg=false, token
    # set buyer or seller name 
    name = slrFlg ? model.owner_name : model.buyer_name 

    # add customer
    customer = Balanced::Customer.new(name: name, email: model.email).save

    # set user token
    model.user.acct_token = customer.uri
    model.user.save

    return customer

    rescue => ex
      process_error model, ex
  end

  # process result data
  def self.process_result result, txn 
    txn.confirmation_no, txn.payment_type, txn.credit_card_no = result.id, result.source.card_type, result.source.last_four
    txn
  end

  # process credit card messages
  def self.process_error acct, e
    acct.errors.add :base, "Account declined or invalid. Please re-submit."
    Rails.logger.info "Request failed: #{e.message}" 
    acct
  end
end
