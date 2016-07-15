# used to process Stripe payments
module StripePayment
  include CalcTotal

  # charge card
  def self.charge_card txn
    Rails.logger.info "PXB charge card: #{txn.token} destination: #{txn.seller_token}"

    # get adjusted convenience fee
    adj_fee = CalcTotal::get_adjusted_conv_fee txn.amt, txn.seller_inv_amt.to_f

    # charge card
    Rails.logger.info "PXB charge amt: #{txn.amt} fee: #{adj_fee}"
    if txn.token.match(/tok_/).nil?
      card_id = txn.user.card_accounts.get_default_acct.card_token rescue nil
    else
      card = create_card txn.user.card_accounts.build(token: txn.token, zip: txn.zip), true
      card_id = card.id
    end

    id = txn.user.reload.cust_token
    Rails.logger.info "PXB charge_card cust_token: #{id}"
    Rails.logger.info "PXB charge_card card_id: #{card_id}"

    result = Stripe::Charge.create(:amount => (txn.amt * 100).to_i, :currency => "usd", :customer => id, :description => txn.description,
      :destination => txn.seller_token, card: card_id, :application_fee => (adj_fee*100).to_i) 
    return result

    # rescue errors
    rescue Stripe::CardError => e
      process_error txn, e
    rescue Stripe::AuthenticationError => e
      process_error txn, e
    rescue Stripe::InvalidRequestError => e
      process_error txn, e
    rescue Stripe::APIConnectionError => e
      process_error txn, e
    rescue Stripe::StripeError => e
      ExceptionNotifier::Notifier.exception_notification('StripeError', e).deliver if Rails.env.production? || Rails.env.staging? || Rails.env.demo?
      process_error txn, e
    rescue => e
      process_error txn, e
  end

  # process result data
  def self.process_result result, txn 
    txn.confirmation_no, txn.payment_type, txn.credit_card_no = result.id, result.card.brand, result.card.last4
    txn
  end

  # process credit card messages
  def self.process_error acct, e
    acct.errors.add :base, "Account declined or invalid. Please re-submit." if acct
    Rails.logger.info "Request failed: #{e.message}" 
    acct
  end

  # set buyer or seller name 
  def self.set_token model, slrFlg=false, token, ip
    name = slrFlg ? model.owner_name : model.buyer_name 

    # add customer
    if slrFlg
      Rails.logger.info "PXB adding account email: #{model.email} token: #{token}"
      account = Stripe::Account.create(country: 'US', email: model.email, managed: true)
      model.user.acct_token = account.id
    else
      Rails.logger.info "PXB adding customer: #{name} token: #{token}"
      account = Stripe::Customer.create(description: name, email: model.email, source: token)
      model.user.cust_token = account.id
    end

    # set user token
    model.user.save
    return account

    rescue => ex
      process_error model, ex
  end

  # complete settings for managed accounts
  def self.update_account model, acct_id, ip
    Rails.logger.info "PXB updating account: #{acct_id} ip: #{ip}"
    acct = Stripe::Account.retrieve(acct_id)
    if acct
      btype = model.is_business? ? 'company' : 'individual'
      acct.legal_entity.type = btype
      acct.tos_acceptance.date = Time.now.to_i
      acct.tos_acceptance.ip = ip
      acct.legal_entity.first_name, acct.legal_entity.last_name = model.first_name, model.last_name
      acct.legal_entity.business_name = model.business_name if model.is_business?
      acct.legal_entity.dob.day, acct.legal_entity.dob.month, acct.legal_entity.dob.year = model.birth_date.day, model.birth_date.month, 
        model.birth_date.year 
      acct.legal_entity.business_tax_id, acct.legal_entity.ssn_last_4 = model.ein, model.ssn_last4 if model.ein
      if model.has_address?
        acct.legal_entity.address.city, acct.legal_entity.address.line1, acct.legal_entity.address.postal_code, acct.legal_entity.address.state = 
 	  model.contacts[0].city, model.contacts[0].address, model.contacts[0].zip, model.contacts[0].state
      end
      acct.save
    end

    rescue => ex
      process_error model, ex
  end

  # get customer 
  def self.get_customer id, txn, slrFlg=false, token='', ip=''
    unless id.blank?
      Rails.logger.info "PXB get_customer by id: #{id}"
      customer = !slrFlg ? Stripe::Customer.retrieve(id) : Stripe::Account.retrieve(id) rescue nil
      customer = set_token txn, slrFlg, token, ip unless customer
    else
      Rails.logger.info "PXB get_customer by token: #{token}"
      customer = set_token txn, slrFlg, token, ip
    end
    # check_for_card customer, txn, token, slrFlg unless slrFlg
    return customer

    rescue => ex
      process_error txn, ex
  end

  # check if buyer has just a seller account
  def self.check_for_card customer, txn, token, slrFlg
    Rails.logger.info "PXB checking card: #{token}"
    unless slrFlg
      if !txn.card_number.blank?
        add_card_account(customer, txn, token) 
      elsif !txn.user.has_card_account?
        add_card_account(customer, txn, token) 
      end
    end
  end

  # assign card account to customer
  def self.assign_card card, acct, token, saveFlg=false
    Rails.logger.info "PXB assign card: #{card.id}"
    acct.card_token, acct.card_no, acct.expiration_month, acct.expiration_year, acct.card_type, acct.token = card.id, card.last4, 
      card.exp_month, card.exp_year, card.brand.titleize, token if card
    acct.save! if saveFlg
  end

  # create card account
  def self.create_card acct, saveFlg=false
    Rails.logger.info "PXB create card: #{acct.token}"
    Rails.logger.info "PXB create cust token: #{acct.cust_token}"

    customer = get_customer acct.cust_token, acct, false, acct.token
    if acct.cust_token && acct.user.has_card_account?
      Rails.logger.info "existing customer w/ new card"
      card = customer.sources.create(:source => acct.token) if customer
    else
      Rails.logger.info "new customer w/ new card"
      card = customer.sources.data.last if customer
    end

    # assign card fields
    assign_card card, acct, acct.token, saveFlg if card
    return card

    rescue => ex
      process_error acct, ex
  end

  # add card account
  def self.add_card_account customer, model, token

    # add card to db
    Rails.logger.info "PXB stripe add card account: #{token}"
    CardAccount.add_card(model, token)

    rescue => ex
      process_error model, ex
  end

  #  add bank account to managed account
  def self.add_bank_account acct, ip
    Rails.logger.info "PXB add bank account w/ token: #{acct.acct_token}"

    # determine account
    account = get_customer acct.acct_token, acct, true, nil, ip

    # add account to customer record
    Rails.logger.info "PXB calling update account w/ token: #{acct.acct_token}"
    update_account acct.user, acct.acct_token, ip if account && account.tos_acceptance.date.blank?
    
    if acct.token.blank?
      Rails.logger.info "PXB calling external account w/ token: #{acct.acct_token}"
      bank = account.external_accounts.create(external_account: {object: 'bank_account', currency: acct.currency_type_code, 
        country: acct.country_code, routing_number: acct.routing_number, account_number: acct.acct_number})
      acct.token = bank.id
      acct.bank_name = bank.bank_name
      acct.acct_no = bank.last4
    else
      account.bank_account = acct.token
      account.save
      acct.bank_name = account.bank_accounts.data.last.bank_name
      acct.acct_no = account.bank_accounts.data.last.last4
    end

    return account

    rescue => ex
      process_error acct, ex
  end

  # credit bank account
  def self.credit_account token, amt, acct

    # credit account
    result = Stripe::Transfer.create(amount: (amt * 100).to_i, currency: "usd", destination: token) if amt > 0.0

    rescue => ex
      process_error acct, ex
  end

  # get account
  def self.get_bank_account token, acct

    # get buyer token
    id = acct.user.acct_token

    # determine account
    account = get_customer id, acct, true
    account.bank_accounts.data.first 

    rescue => ex
      process_error acct, ex
  end

  def self.credit_seller_account model
    Rails.logger.info "in credit seller account"
    fee = CalcTotal::get_adjusted_conv_fee model.transaction_amount, model.seller_amount.to_f
    result = Stripe::Charge.retrieve(model.confirmation_no)

    # record payment & send receipt
    if result
      Payment::add_transaction(model, fee, result)
      UserMailer.send_payment_receipt(model, result).deliver rescue nil 
    end

    rescue => ex
      process_error model, ex
  end

  # delete stored card
  def self.delete_card token, model
    customer = get_customer model.cust_token, model, true
    card = customer.sources.retrieve(model.card_token).delete() if customer

    rescue => ex
      process_error model, ex
  end

  # delete stored account
  def self.delete_account token, model
    account = get_customer model.acct_token, model, false
    bank = account.sources.retrieve(model.token).delete() if account

    rescue => ex
      process_error model, ex
  end

  # add plan
  def self.add_plan model
    Stripe::Plan.create(amount: (model.price*100).to_i,
      interval: model.interval, name: model.name, currency: 'usd',
      statement_descriptor: "Pixiboard #{model.name}",
      trial_period_days: model.trial_days, id: SecureRandom.uuid)

    rescue => ex
      process_error model, ex
  end

  # update plan
  def self.update_plan model, name
    plan = get_plan(model)
    plan.name = name
    plan.save
    plan

    rescue => ex
      process_error model, ex
  end

  # get stripe plan
  def self.get_plan model
    Stripe::Plan.retrieve(model.stripe_id)

    rescue => ex
      process_error model, ex
  end

  # remove plan
  def self.remove_plan model
    plan = get_plan(model)
    plan.delete

    rescue => ex
      process_error model, ex
  end

  # add subscription
  def self.add_subscription model
    acct = model.card_account
    customer = get_customer(acct.cust_token, acct)
    customer.subscriptions.create(plan: model.plan.stripe_id)

    rescue => ex
      process_error model, ex
  end

  # get subscription
  def self.get_subscription model
    acct = model.card_account
    customer = get_customer(acct.cust_token, acct)
    customer.subscriptions.retrieve(model.stripe_id)

    rescue => ex
      process_error model, ex
  end

  # cancel subscription
  def self.cancel_subscription model
    sub = get_subscription(model)
    sub.delete

    rescue => ex
      process_error model, ex
  end

  # update subscription
  def self.update_subscription model, plan_stripe_id
    sub = get_subscription(model)
    sub.plan = Stripe::Plan.retrieve(plan_stripe_id)
    sub.save

    rescue => ex
      process_error model, ex
  end
end
