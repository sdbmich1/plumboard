module BankAccountsHelper

  # set path based on action
  def set_account_path usr
    if action_name == 'new'  
      bank_accounts_path(@account, uid: usr, target: @target, adminFlg: @adminFlg, format: 'js') 
    else 
      bank_accounts_path(@account, uid: usr, target: @target, adminFlg: @adminFlg)
    end 
  end

  # toggle btn name based on target
  def set_btn_name
    !(@target =~ /invoice/i).nil? ? 'Next' : 'Save'
  end

  # set partial name
  def set_acct_partial_name
    @target ||= 'shared/invoice_form'
  end

  def set_bank_acct_path
    if @user.has_bank_account?
      @acct = @user.bank_accounts.first
      @acct.new_record? ? new_bank_account_path : bank_account_path(@acct)
    else
      new_bank_account_path
    end
  end

  def show_bank_icon bank
    case bank.acct_type
      when 'Visa'; fname = 'visa.png'
      when 'Master Card'; fname = 'mastercard.png'
      else fname = '190-bank.png'
    end
    image_tag("#{fname}", class: 'camera')
  end

  def toggle_bank_list
    adminMode? ? 'shared/bank_list_details' : 'shared/bank_acct_details'
  end
end
