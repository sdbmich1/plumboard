module CardAccountsHelper

  # determine card path 
  def get_card_path
    @user.active_card_accounts.size > 0 ? card_account_path(@user.active_card_accounts.first) : new_card_account_path 
  end
end
