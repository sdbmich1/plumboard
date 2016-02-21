module CardAccountsHelper

  # determine card path 
  def get_card_path
    if adminMode?
      card_accounts_path(adminFlg: @adminFlg)
    else
      @usr.has_card_account? ? card_accounts_path(uid: @usr, adminFlg: @adminFlg) : new_card_account_path(uid: @usr)
    end
  end

  def toggle_card_list_title
    @adminFlg ? 'Manage Accounts' : 'My Accounts'
  end

  def toggle_card_list
    adminMode? ? 'shared/card_list_details' : 'shared/card_acct_details'
  end

  def show_card_icon card
    case card.card_type
      when 'American Express'; fname = 'amex.png'
      when "Diners Club"; fname = 'diners.png'
      when "Jcb"; fname = 'jcb.png'
      when "Discover"; fname = 'discover.png'
      when 'Visa'; fname = 'visa.png'
      when 'Master Card'; fname = 'mastercard.png'
    end
    image_tag("#{fname}", class: 'camera')
  end

  def show_exp_date card
    "#{card.expiration_month} / #{card.expiration_year}" if card
  end

  def show_card_holder acct, fld="buyer_name", cls="center-wrapper"
    content_tag(:td, acct.send(fld), class: cls) if @adminFlg
  end

  def show_card_holder_title val='Card'
    content_tag(:th, "#{val} Holder", class: "center-wrapper")
  end

  def new_card_path
    adminMode? ? new_card_account_path(adminFlg: @adminFlg) : new_card_account_path(uid: @usr, adminFlg: @adminFlg)
  end

  def show_card_account account
    if account
      render partial: 'shared/show_card_acct_details', locals: {account: account}
    else
      content_tag(:div, 'Account not found for given user.', class:'center-wrapper mtop')
    end
  end

  def load_holder
    params[:uid].blank? ? '' : @usr.name
  end

  def adminMode? 
    @usr.is_admin? && @adminFlg rescue false
  end

  def set_holder_id
    adminMode? ? nil : @usr.id
  end

  def show_acct_holder f, val='card'
    render partial: "shared/#{val}_acct_holder", locals: {f: f} if @adminFlg
  end

  def show_form_field f, type
    f.hidden_field :card_no if type == 'card'
  end
end
