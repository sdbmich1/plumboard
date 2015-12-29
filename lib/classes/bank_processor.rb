class BankProcessor
  include Payment

  def initialize acct
    @acct = acct
  end

  def must_have_token
    if @acct.token.blank?
      @acct.errors.add(:base, 'Must have a token')
      false
    else
      true
    end
  end

  # set flds
  def set_flds
    @acct.status, @acct.default_flg = 'active', 'Y' unless @acct.user.has_bank_account?
  end

  # get account
  def get_account
    Payment::get_bank_account @acct.token, @acct

    # check for errors
    return false if @acct.errors.any?
  end

  # add new account
  def save_account ip	
    acct = Payment::add_bank_account @acct, ip

    # check for errors
    result = process_error acct, "Account number, routing number, or account name is invalid."

    # save new account
    result ? @acct.save! : false
  end

  # issue account credit
  def credit_account amt
    result = Payment::credit_account @acct.token, amt, @acct

    # check for errors
    process_error result, "Error: There was a problem with your bank account."
  end

  # process eror
  def process_error result, msg
    if result 
      @acct.errors.any? ? false : result 
    else
      @acct.errors.add :base, msg
      false
    end
  end

  # delete account
  def delete_account
    # result = Payment::delete_account @acct.token, @acct if @acct.token

    # check for errors
    # val = process_error result, "Error: There was a problem with your bank account."
    @acct.update_attributes(status: 'removed', default_flg: nil) # if val
  end

  # return list of acct holders or list of accts for a given user based on params
  def acct_list usr, aFlg
    if usr.is_admin? && aFlg  
      User.joins(:bank_accounts).include_list.where('bank_accounts.status = ?', 'active').uniq.reorder('first_name ASC')  
    else
      BankAccount.inc_list.where(user_id: usr, status: 'active')
    end
  end
end
