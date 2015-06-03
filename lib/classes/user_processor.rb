class UserProcessor
  include LocationManager, PointManager, ImageManager, NameParse

  def initialize usr
    @user = usr
  end

  # create unique url for user
  def generate_url value, cnt=0
    begin
      new_url = cnt == 0 ? value.gsub(/\s+/, "") : [value.gsub(/\s+/, ""), cnt.to_s].join('')
      cnt += 1
      new_url = NameParse::transliterate new_url, true, true
    end while User.where(:url => new_url).exists?
    new_url
  end

  # update points & send notice
  def process_data
    ptype = @user.uid.blank? ? 'dr' : 'fr'
    PointManager::add_points @user, ptype

    # send welcome message to facebook users
    UserMailer.delay.welcome_email(@user) if @user.fb_user?
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
      @user.pixi_posts.update_all({user_id: usr.id, status: 'active'}, {})
      @user.contacts.update_all(contactable_id: usr.id) unless usr.has_address? 
      @user.temp_listings.update_all({seller_id: usr.id, status: 'new'}, {})
    end
  end

  # display image with name for autocomplete
  def pic_with_name
    pic = @user.photo rescue nil
    pic ? "<img src='#{pic}' class='inv-pic' /> #{@user.name}" : nil
  end

  # display image with name for autocomplete
  def pic_with_business_name
    pic = @user.photo rescue nil
    pic ? "<img src='#{pic}' class='inv-pic' /> #{@user.business_name}" : nil
  end

  # set csv filename
  def filename utype
    (utype.blank? ? "All" : UserType.where(code: utype).first.description) + "_" + ResetDate::set_file_timestamp
  end

  def csv_data
    { "Name" => @user.name, "Email" => @user.email, "Home Zip" => @user.home_zip, "Birth Date" => @user.birth_dt, 
      "Enrolled" => nice_date(@user.created_at), "Last Login" => nice_date(@user.last_sign_in_at), "Gender" => @user.gender, "Age" => @user.age }
  end

  # initialize data
  def set_flds
    NameParse::encode_string @user.description if @user.description
    @user.user_type_code = 'MBR' if @user.user_type_code.blank?
    @user.user_url, @user.status = @user.name, 'active' unless @user.guest?
  end

  # convert date/time display
  def nice_date(tm, tmFlg=true)
    ll = LocationManager::get_lat_lng_by_zip @user.home_zip
    ResetDate::display_date_by_loc tm, ll, tmFlg rescue Time.now.strftime('%m/%d/%Y %l:%M %p')
  end

  # used to add pictures for new user
  def with_picture
    @user.pictures.build if @user.pictures.blank? || @user.pictures.size < 2
    @user.preferences.build if @user.preferences.blank?
    @user
  end

  def get_mbr_type
    @user.is_business? ? 'biz' : 'mbr'
  end

  def url_str
    ['https://pixiboard.com/', get_mbr_type, '/'].join('')
  end

  # getter for url
  def user_url 
    [url_str, @user.url].join('') rescue nil
  end

  def local_user_path
    ['/', get_mbr_type, '/', @user.url].join('') rescue nil
  end

  # get active sellers by category and/or location
  def get_seller_ids cat, loc
    Listing.get_by_city(cat, loc).uniq.pluck(:seller_id)
  end

  # get seller list based on category and location
  def get_sellers cat, loc
    User.includes(:pictures, :preferences).active.get_by_type('BUS').where(id: get_seller_ids(cat, loc)).select { |usr| usr.pixi_count > 1 }
  end

  # get site name from zip
  def site_name
    LocationManager::get_loc_name nil, nil, @user.home_zip
  end
end
