  # Returns the full title on a per-page basis.
  def full_title page_title
    base_title = "Pixiboard"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # format time
  def get_local_time(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y %I:%M%p') rescue nil
  end

  # format short date
  def short_date(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y') rescue nil
  end

  # format short time
  def short_time tm
    tm.utc.getlocal.strftime('%I:%M%p') rescue nil
  end

  # get conv fee message based on user
  def get_conv_fee_msg inv
    if inv
      inv.owner?(@user) ? inv.listing.pixi_post? ? PXPOST_FEE_MSG : SELLER_FEE_MSG : CONV_FEE_MSG
    end
  end

  # get conv fee title
  def get_conv_title inv
    str = inv.owner?(@user) && action_name == 'show' ? 'Less ' : '' rescue ''
    str + 'Convenience Fee'
  end

  # get invoice fee based on user
  def get_invoice_fee inv
    inv.owner?(@user) ? inv.get_fee(true) : inv.get_fee rescue 0
  end

  # get invoice total based on user
  def get_invoice_total inv
    inv.owner?(@user) ? inv.amount : inv.amount + inv.get_fee rescue 0
  end

  # add regoin for specs
  def add_region
    stub_const("PIXI_LOCALE", 'Metro Detroit')
    @usr = FactoryGirl.create :pixi_user, confirmed_at: Time.now 
    @site1 = create :site, name: 'Detroit', org_type: 'city'
    @site1.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI', zip: '48238'
    @site2 = create :site, name: 'Metro Detroit', org_type: 'region'
    @site2.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI', zip: '48238'
    @pixi = create(:listing, title: "Guitar", description: "Lessons", seller_id: @usr.id, site_id: @site1.id) 
    @loc = @site1.id
  end

  # login method for given user
  def init_setup usr
    login_as(usr, :scope => :user, :run_callbacks => false)
    @user = usr
  end

  # set pixi count constant
  def set_const val
    stub_const("MIN_PIXI_COUNT", val)
    expect(MIN_PIXI_COUNT).to eq(val)
  end

  # set credit card constant
  def set_payment_const val
    stub_const("CREDIT_CARD_API", val)
    expect(CREDIT_CARD_API).to eq(val)
  end

  # check if user has bank account to determine correct routing
  def get_invoice_path
    form = 'shared/invoice_form'
    @user.has_bank_account? ? new_invoice_path : new_bank_account_path(target: form)
  end
