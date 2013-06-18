module BankAccountsHelper

  # set path based on action
  def set_account_path
    action_name == 'new' ? bank_accounts_path(@account, target: @target, format: 'js') : bank_account_path(@account, target: @target)
  end

  def set_btn_name
    !(@target =~ /invoice/i).nil? ? 'Next' : 'Save'
  end
end
