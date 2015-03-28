class CardProcessor
  include Payment

  def initialize acct
    @acct = acct
  end

  # delete saved cards
  def remove_cards uid
    usr = User.find uid
    usr.card_accounts.delete_all if usr.has_card_account?
  end

  # create card
  def save_card
    card = Payment::create_card @acct.card_number, @acct.expiration_month, @acct.expiration_year, @acct.card_code, @acct.zip

    # check for errors
    unless card.blank? 
      return false if @acct.errors.any?

      # set fields
      @acct.token, @acct.card_no, @acct.expiration_month, @acct.expiration_year, @acct.card_type = card.uri, card.last_four, card.expiration_month, 
        card.expiration_year, card.card_type.titleize

      Rails.logger.info "PXB Save Account: #{@acct.token} number: #{@acct.card_no}" 
      result = Payment::assign_card @acct.user.acct_token, @acct.token
    else
      @acct.errors.add :base, "Card info is invalid. Please re-enter."
      return false
    end

    # save new account
    @acct.save
  end

  # add card
  def add_card model, token
    remove_cards(model.user)  # remove old cards to make this card the default

    # get last 4 of card
    card_num = model.card_number[model.card_number.length-4..model.card_number.length] rescue nil

    # check if card exists
    unless card = model.user.card_accounts.where("card_no = ?", card_num).first
      card = model.user.card_accounts.build card_no: card_num, expiration_month: model.exp_month,
	         expiration_year: model.exp_year, card_code: model.cvv, zip: model.zip, card_type: model.payment_type 

      # check if token was already created
      if token && model.user.acct_token
        Payment::assign_card model.user.acct_token, token
        card.token = token
	result = card.save
      else
        result = card.save_account 
      end
    end
    card.errors.any? || !result ? false : card 
  end

  # delete card from svc provider
  def delete_card
    result = Payment::delete_card @acct.token, @acct if @acct.token

    # remove card
    if result 
      @acct.errors.any? ? false : @acct.destroy 
    else
      @acct.errors.add :base, "Error: There was a problem with your account."
      false
    end
  end
end
