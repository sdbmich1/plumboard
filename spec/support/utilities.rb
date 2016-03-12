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
    @site1 = create :site, name: 'Detroit', site_type_code: 'city'
    @site1.contacts.create FactoryGirl.attributes_for :contact, address: 'Metro', city: 'Detroit', state: 'MI', zip: '48238'
    @site2 = create :site, name: 'Metro Detroit', site_type_code: 'region'
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

  # get invoice fee based on user
  def get_invoice_fee inv
    inv.owner?(@user) ? inv.get_fee(true) : inv.get_fee rescue 0
  end

  def accept_btn
    click_button 'OK'
    # page.driver.browser.switch_to.alert.accept
    # wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
    # alert = wait.until { page.driver.browser.switch_to.alert }
    # alert.accept
  end

  def click_ok
    click_button submit; sleep 3 
    click_button 'OK'
    # page.driver.browser.switch_to.alert.accept
  end

  def click_submit
    click_button submit
  end

  def click_valid_ok
    click_button submit
    # page.driver.browser.switch_to.alert.accept
    sleep 2
    accept_btn
    sleep 2
  end

  def click_valid_save
    click_button save 
    sleep 3
  end

  def click_cancel_ok
    click_link 'Cancel'; sleep 1 
    click_button 'OK'
    # page.driver.browser.switch_to.alert.accept
  end

  def click_cancel
    click_button 'Cancel'
    # page.driver.browser.switch_to.alert.dismiss
  end

  def click_cancel_cancel
    click_link 'Cancel'; sleep 1 
    click_button 'Cancel'
    # page.driver.browser.switch_to.alert.dismiss
  end

  def click_submit_cancel
    click_button submit; sleep 1 
    click_button 'Cancel'
    # page.driver.browser.switch_to.alert.dismiss
  end

  def click_remove_ok
    click_link 'Remove'
    click_button 'OK'
    # page.driver.browser.switch_to.alert.accept
  end
	                  
  def click_remove_cancel
    click_link 'Remove'
    click_button 'Cancel'
    # page.driver.browser.switch_to.alert.dismiss
  end
  
  def user_login usr
    fill_in "user_email", :with => usr.email
    fill_in "pwd", :with => usr.password
    click_button "Sign in"
  end

  def check_page_expectations str_arr, txt, notFlg=true
    str_arr.each do |str|
      if notFlg
        page.should_not have_content "#{str} #{txt}"
      else
        page.should have_content "#{str}#{txt}"
      end
    end
  end

  def check_page_selectors str_arr, vFlg, notFlg=true
    str_arr.each do |str|
      if notFlg
        page.should_not have_selector("#{str}", visible: vFlg)
      else
        page.should have_selector("#{str}", visible: vFlg)
      end
    end
  end

  def invalid_card_dates
    select "January", from: "card_month"
    select (Date.today.year).to_s, from: "card_year"
  end

  def valid_card_dates
    select "January", from: "card_month"
    select (Date.today.year+2).to_s, from: "card_year"
  end

  def credit_card val="4111111111111111"
    fill_in "card_number", with: val
  end

  def credit_card_data cid="4111111111111111", cvv="123", valid=true
    credit_card cid
    fill_in "card_code",  with: cvv
    valid ? valid_card_dates : invalid_card_dates
    click_valid_ok
  end

  def valid_dates
    select "January", from: "card_month"
    select (Date.today.year+2).to_s, from: "card_year"
  end

  def load_credit_card cid="4111111111111111", cvv="123", valid=true, flg=true
    credit_card cid
    fill_in "card_code",  with: cvv
    valid ? valid_dates : invalid_card_dates
    fill_in "card_zip",  with: '94103'
    page.execute_script %Q{ $("#card_account_user_id").val("#{@other.id}") } if @other
    flg ? click_valid_save : click_submit
  end

  def create_user_types
    create :user_type, code: 'MBR', description: 'Individual', hide: 'no'
    create :user_type, code: 'BUS', description: 'Business', hide: 'no'
    create :user_type, code: 'SUB', description: 'Subscriber', status: 'active'
    create :user_type, code: 'PX', description: 'Pixter', status: 'active'
  end

  def send_mailer model, msg
    @mailer = mock(UserMailer)
    UserMailer.stub!(:delay).and_return(@mailer)
    @mailer.stub(msg.to_sym).with(model).and_return(@mailer)
  end

    def reg_user_info
      fill_in "user_first_name", with: 'Jill'
      fill_in "user_last_name", with: 'Jones'
    end

    def reg_user_birth_date
      select('Jan', :from => "user_birth_date_2i")
      select('10', :from => 'user_birth_date_3i')
      select('1983', :from => 'user_birth_date_1i')
    end

    def reg_user_pwd
      fill_in 'user_password', :with => 'userpassword'
      # fill_in "user_password_confirmation", with: 'userpassword'
    end

    def reg_user_data flg=true
      reg_user_info
      fill_in 'email', :with => 'newuser@example.com'
      if flg
        select('Male', :from => 'user_gender')
        select('Individual', :from => 'ucode')
      else
        select('Business', :from => 'ucode')
        fill_in 'user_business_name', :with => 'Company A'
      end
      reg_user_birth_date
      fill_in 'home_zip', :with => '90201'
      reg_user_pwd
    end

    def add_data_w_photo
      # attach_file('user[pictures_attributes][0][photo]', Rails.root.join("spec", "fixtures", "photo.jpg"))
      # attach_file('user_pictures_attributes_0_photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
      attach_file('user_pic', Rails.root.join("spec", "fixtures", "photo.jpg"))
    end

    def reg_user_with_photo flg=true
      reg_user_data flg
      # add_data_w_photo
    end

    def register val="YES", cnt=1, flg=true
      expect { 
        stub_const("USE_LOCAL_PIX", val)
        reg_user_with_photo
        click_button submit; sleep 2 
        page.should have_content 'A message with a confirmation link has been sent to your email address' if cnt > 0
      }.to change(User, :count).by(cnt)
    end

    def omniauth eFlg=true
      email = eFlg ? 'bob.smith@test.com' : ''
      OmniAuth.config.add_mock :facebook,
        uid: "fb-12345", info: { name: "Bob Smith", image: "https://graph.facebook.com/708798320/picture?type=square", 
	location: 'San Francisco, California' },
        extra: { raw_info: { first_name: 'Bob', last_name: 'Smith',
        email: email, birthday: "01/03/1989", gender: 'male' } }
    end

  def set_temp_attr uid
    @attr = {"title"=>"Tribe Designer Table Lamp", "category_id"=>"31", "condition_type_code"=>"N", "job_type_code"=>"", 
      "event_type_code"=>"", "site_id"=>"9973", "price"=>"250", "quantity"=>"1", "year_built"=>"", "compensation"=>"", "event_start_date"=>"", 
      "event_end_date"=>"", "car_id"=>"", "car_color"=>"", "mileage"=>"", "item_color"=>"", "item_size"=>"", "item_id"=>"", 
      "description"=>"great for your new home.", "start_date"=>"2015-04-09 19:50:49 -0700", "status"=>"new", "seller_id"=>"#{uid}", 
      "post_ip"=>"127.0.0.1", "pictures_attributes"=>{"0"=>{"direct_upload_url"=>
      "https://pixibucket02.s3-us-west-1.amazonaws.com/uploads/1428634318430-866cf4fkl3-6c0edffe786507255b8e72f246d301ad/1ktribe-t1-table-lamp.jpg", 
      "photo_file_name"=>"1ktribe-t1-table-lamp.jpg", 
      "photo_file_path"=>"/uploads/1428634318430-866cf4fkl3-6c0edffe786507255b8e72f246d301ad/1ktribe-t1-table-lamp.jpg", "photo_file_size"=>"42817", 
      "photo_content_type"=>"image/jpeg"}}}
  end

  def update_pixi pixi, val, amt
    pixi.end_date = Date.today + amt.days
    pixi.status = val
    pixi.save
    pixi.reload
  end

  def new_conv mtype
    @pixi = create :listing, seller_id: @user.id, title: 'Big Guitar'
    @conv = @pixi.conversations.build attributes_for :conversation, user_id: @user.id, recipient_id: @recipient.id, quantity: 2
    @new_post = @conv.posts.build attributes_for :post, user_id: @user.id, recipient_id: @recipient.id, pixi_id: @pixi.pixi_id, msg_type: mtype
    @conv.save!
  end

  def add_bank_data
    fill_in 'routing_number', with: '110000000'
    fill_in 'acct_number', with: '000123456789'
    fill_in 'bank_account_acct_name', with: "SDB Business"
    fill_in 'bank_account_description', with: "My business"
    page.execute_script %Q{ $("#bank_account_user_id").val("#{@other.id}") } if @other
    select("checking", :from => "bank_account_acct_type")
  end
