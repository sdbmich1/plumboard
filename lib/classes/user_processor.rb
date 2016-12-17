class UserProcessor
  include LocationManager, PointManager, ImageManager, NameParse, ProcessMethod, RatingManager

  def initialize usr
    @user = usr
  end

  # validate picture exists
  def must_have_picture
    check_for_errors @user.any_pix?, 'Must have a picture'
  end

  # validate zip exists
  def must_have_zip
    if @user.provider.blank?
      result = !@user.home_zip.blank? && (@user.home_zip.length == 5 && @user.home_zip.to_region) 
      check_for_errors result, 'Must have a valid zip'
    else
      true
    end
  end

  # process any errors
  def check_for_errors flg, str
    flg ? true : add_error(str)
  end

  def add_error str
    @user.errors.add(:base, str)
    false
  end

  # create unique url for user
  def generate_url value, cnt=0
    ProcessMethod::generate_url 'User', value, cnt
  end

  # update points & send notice
  def process_data
    ptype = @user.uid.blank? ? 'dr' : 'fr'
    PointManager::add_points @user, ptype

    # send welcome message to facebook users
    UserMailer.welcome_email(@user).deliver_later if @user.fb_user?
  end

  # build url image
  def add_url_image usr, token
    ImageManager::parse_url_image(usr.pictures.build, token.info.image.sub("square","large"))
  end

  # determine age
  def calc_age
    if @user.birth_date
      now = Time.now.utc.to_date
      had_birthday_this_year = now.month > @user.birth_date.month || (now.month == @user.birth_date.month && now.day >= @user.birth_date.day)
      now.year - @user.birth_date.year - (had_birthday_this_year ? 0 : 1)
    else
      nil
    end
  end

  # check for address
  def has_address?
    @user.contacts.build if @user.contacts.blank?
    if @user.contacts[0]
      !@user.contacts[0].address.blank? && !@user.contacts[0].city.blank? && !@user.contacts[0].state.blank? && !@user.contacts[0].zip.blank?
    else
      false
    end
  end

  # check for prefs
  def has_prefs?
    @user.preferences.build if @user.preferences.blank?
    if @user.preferences[0]
      !@user.preferences[0].fulfillment_type_code.blank? && !@user.preferences[0].sales_tax.blank? && !@user.preferences[0].ship_amt.blank? 
    else
      false
    end
  end

  # get message count
  def unread_count
    Post.unread_count @user rescue 0
  end

  # converts date format
  def convert_date(old_dt)
    Date.strptime(old_dt, '%m/%d/%Y') if old_dt    
  end  

  # load facebook data
  def load_facebook_user access_token, signed_in_resource
    data = access_token.extra.raw_info
    unless user = User.where(:email => data.email).first
      user = User.new(:first_name => data.first_name, :last_name => data.last_name, 
	      :birth_date => convert_date(data.birthday), :provider => access_token.provider, :uid => access_token.uid, :email => data.email) 
      user.password = user.password_confirmation = Devise.friendly_token[0,20]
      user.fb_user = true
      user.gender = data.gender.capitalize rescue nil
      user.home_zip = LocationManager::get_home_zip(access_token.info.location) rescue nil
      add_url_image user, access_token
      user.email.blank? ? false : user.save(:validate => false)
    end
    user
  end

  # transfer data between user accounts
  def move_to usr
    if usr
      @user.pixi_posts.update_all({user_id: usr.id, status: 'active'})
      @user.contacts.update_all(contactable_id: usr.id) unless usr.has_address? 
      @user.temp_listings.update_all({seller_id: usr.id, status: 'new'})
    end
  end

  # display image with name for autocomplete
  def pic_with_name
    pic = @user.photo rescue nil
    pic ? "<img src='#{pic}' class='thumb-size pic-item' /> #{@user.name}" : nil
  end

  # display image with name for autocomplete
  def pic_with_business_name
    pic = @user.photo rescue nil
    pic ? "<img src='#{pic}' class='thumb-size pic-item' /> #{@user.business_name}" : nil
  end

  # set csv filename
  def filename utype
    (utype.blank? ? "All" : UserType.where(code: utype).first.description) + "_" + ResetDate::set_file_timestamp
  end

  def csv_data
    output = { "Name" => @user.name, "Email" => @user.email, "Type" => @user.type_descr,
               "Zip" => @user.home_zip, "Birth Date" => @user.birth_dt,
               "Enrolled" => nice_date(@user.created_at) }
    output['Last Login'] = nice_date(@user.current_sign_in_at) if @user.current_sign_in_at
    output
  end

  # initialize data
  def set_flds
    @user.description = nil unless @user.description.blank?
    @user.user_type_code = 'MBR' if @user.user_type_code.blank?
    @user.user_url, @user.status = @user.name, 'active' if @user.status.blank? && !@user.guest?
    NameParse::encode_string @user.business_name unless @user.business_name.blank?
  end

  # convert date/time display
  def nice_date(tm, tmFlg=true)
    ll = LocationManager::get_lat_lng_by_zip @user.home_zip
    ResetDate::display_date_by_loc tm, ll, tmFlg rescue Time.now.strftime('%m/%d/%Y %l:%M %p')
  end

  # used to add pictures for new user
  def with_picture addFlg=true
    @user.pictures.build if addFlg && (@user.pictures.blank? || @user.pictures.size < 2)
    @user.preferences.build if @user.preferences.blank?
    @user
  end

  def get_mbr_type
    @user.is_business? ? 'biz' : 'mbr'
  end

  def url_str
    [ProcessMethod::get_host, '/', get_mbr_type, '/'].join('')
  end

  # getter for url
  def user_url 
    [url_str, @user.url].join('') rescue nil
  end

  def local_user_path
    ['/', get_mbr_type, '/', @user.url].join('') rescue nil
  end

  def get_ids listings
    listings.map(&:seller_id).uniq rescue nil
  end

  # get seller list based on current pixis
  def get_sellers listings, val='BUS'
    User.includes(:pictures, :preferences).get_by_type(val).board_fields
      .where(id: get_ids(listings)).select {|usr| usr.reload.pixi_count >= min_count}
  end

  def min_count
    Rails.env.production? ? MIN_FEATURED_PIXIS : 2
  end

  # get site name from zip
  def site_name
    LocationManager::get_loc_name nil, nil, @user.home_zip
  end

  def order_txt val
    result = val.is_a?(Array) ? !val.detect{|x| x=='BUS'}.nil? : val.upcase == 'BUS' rescue false
    txt = val && result ? 'business_name ASC' : 'first_name ASC'
  end

  # return users by type
  def get_by_type val
    val.blank? ? User.active : User.active.where(:user_type_code => val).order(order_txt(val))
  end

  # return users following seller_id
  def get_by_seller(seller_id, status)
    favorites = seller_id.blank? ? FavoriteSeller.where(status: status) : FavoriteSeller.where(seller_id: seller_id, status: status)
    User.includes(:preferences, :pictures).where(id: favorites.pluck(:user_id)).order('last_name ASC')
  end

  # return sellers followed by user_id
  def get_by_user(user_id, status)
    favorites = user_id.blank? ? FavoriteSeller.where(status: status) : FavoriteSeller.where(user_id: user_id, status: status)
    User.includes(:preferences, :pictures).where(id: favorites.pluck(:seller_id)).order('business_name ASC')
  end

  # return the date the current user followed seller_id
  def date_followed(seller_id)
    favorite_seller = @user.favorite_sellers.find_by_seller_id_and_status(seller_id, 'active')
    favorite_seller ? favorite_seller.updated_at : nil
  end

  # return the ID of the FavoriteSeller object for the current user and seller_id
  def favorite_seller_id(seller_id)
    favorite_seller = @user.favorite_sellers.find_by_seller_id(seller_id)
    favorite_seller ? favorite_seller.id : nil
  end

  def get_rating
    RatingManager.avg_rating @user
  end

  # get nearest stores by zip
  def get_nearest_stores zip, miles, ctype
    User.where(user_type_code: 'BUS', id: Contact.near(zip, miles).where(contactable_type: ctype).map(&:contactable_id))
  end
end
