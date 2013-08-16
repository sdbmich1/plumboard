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

    @bank_account = Balanced::BankAccount.new(
      account_number: 	acct.acct_number, 
      routing_number: 	acct.routing_number,
      name: 		acct.acct_name,
      type: 		acct.acct_type).save

    rescue => ex
      process_error ex
  end

  # get account
  def self.get_bank_account token, acct

    @acct ||= acct
    @bank_account ||= Balanced::BankAccount.find token

    rescue => ex
      process_error ex
  end

  # credit bank account
  def self.credit_account token, amt, acct
    initialize

    # credit account
    result = get_bank_account(token, acct).credit(amount: (amt * 100).to_i) if amt > 0.0

    rescue => ex
      process_error ex
  end

  # delete bank account
  def self.delete_account token, acct
    initialize

    # find existing account
    result = get_bank_account(token, acct).unstore

    rescue => ex
      process_error ex
  end

  # create card account
  def self.create_card card_no, exp_month, exp_yr, cvv
    initialize

    card = Balanced::Card.create(
      card_number: card_no, 
      expiration_month: exp_month,
      expiration_year: exp_yr, 
      security_code: cvv).save

    rescue => ex
      process_error ex
  end

  # create card account
  def self.charge_card token, amt, descr, txn 
    initialize

    # set buyer
    unless buyer = Balanced::Account.where(email: txn.user.email).first
      buyer = @marketplace.create_buyer(email_address: txn.user.email, card_uri: token)
    else
      buyer
    end

    # charge card
    result = buyer.debit(amount: (amt * 100).to_i.to_s)

    rescue => ex
      process_error ex
  end

  # process result data
  def self.process_result result, txn 
    txn.confirmation_no, txn.payment_type, txn.credit_card_no = result.id, result.source.card_type, result.source.last_four
    txn
  end

  # process credit card messages
  def self.process_error e
    @acct.errors.add :base, "There was a problem with your account. #{e.message}" rescue nil
  end
end
