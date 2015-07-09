class ListingDataProcessor < ListingQueryProcessor
  include Area, ResetDate, LocationManager, NameParse, ProcessMethod

  # set string
  def set_title_str str, prcFlg
    tt = prcFlg ? @listing.title.split('-').map(&:titleize).join('-').html_safe : @listing.title.titleize.html_safe rescue @listing.title 
    if prcFlg
      @listing.title.index('$') ? tt : tt + str 
    else
      @listing.title.index('$') ? tt.split('$')[0].strip! : tt
    end
  end

  # titleize title
  def nice_title prcFlg=true
    unless @listing.title.blank?
      str = (@listing.price.blank? || @listing.price == 0) && !prcFlg ? '' : ' - '
      set_title_str str, prcFlg
    else
      nil
    end
  end

  # delete selected photo
  def delete_photo pid, val=1
    pic = @listing.pictures.where(id: pid).first
    result = pic && @listing.pictures.size > val ? @listing.pictures.delete(pic) : false
    @listing.errors.add :base, "Pixi must have at least one image." unless result
    result
  end

  # check for temp or active pixi based on flag
  def get_listing tmpFlg
    listing = tmpFlg ? Listing.find_by_pixi_id(@listing.pixi_id) : TempListing.find_by_pixi_id(@listing.pixi_id)
    unless listing
      attr = get_attr(tmpFlg)  # copy attributes
      listing = tmpFlg ? Listing.where(attr).first_or_initialize : TempListing.where(attr).first_or_initialize
      listing.status = 'edit' unless tmpFlg
    end
    listing
  end

  # get listing image file ids
  def get_file_ids listing
    file_names = listing.pictures.map(&:photo_file_name) - @listing.pictures.map(&:photo_file_name)
    file_ids = listing.pictures.where(photo_file_name: file_names).map(&:id)
  end

  # update fields
  def update_fields listing, tmpFlg
    listing.assign_attributes(get_attr(tmpFlg), :without_protection => true) 
    listing.status = 'active'
    listing
  end

  # duplicate pixi between models
  def dup_pixi tmpFlg, repost=false
    listing = get_listing tmpFlg
    listing = add_photos tmpFlg, listing
    listing = update_fields listing, tmpFlg if tmpFlg && listing 
    listing.save!
    listing.delete_photo(get_file_ids(listing), 0) if tmpFlg rescue false
    listing
  end

  # get existing attributes
  def get_attr tmpFlg
    arr = tmpFlg ? %w(id created_at updated_at explanation parent_pixi_id buyer_id delta) : %w(id created_at updated_at delta)
    ProcessMethod::get_attr @listing, arr
  end

  # add photos to dup 
  def add_photos tmpFlg, listing
    @listing.pictures.each do |pic|

      # check if listing & photo already exists for pixi edit
      if tmpFlg && !listing.new_record?
        next if listing.pictures.where(:photo_file_name => pic.photo_file_name).first
      end

      # add photo
      listing.pictures.build(:photo => pic.photo, :dup_flg => true)
    end
    listing
  end

  # format date
  def format_date dt
    zip = [@listing.lat, @listing.lng].to_zip rescue nil 
    ResetDate::format_date dt, zip rescue Time.now.strftime('%m/%d/%Y %l:%M %p')
  end

  # format date based on location
  def display_date dt, dFlg=true
    lat, lng = @listing.lat, @listing.lng
    ll = lat && lat > 0 ? [lat, lng] : LocationManager::get_lat_lng_by_loc(@listing.primary_address)
    ResetDate::display_date_by_loc dt, ll, dFlg rescue Time.now.strftime('%m/%d/%Y %l:%M %p')
  end

  # calls rinku method to set html_safe & convert certain text to urls/emails
  def set_auto_link descr
    Rinku.auto_link(descr, :all, 'target="_blank"') rescue nil
  end

  # set string
  def set_str item, val
    descr = item.length < val ? item : item[0..val] + '...' rescue nil
    set_auto_link descr
  end

  # set unique key
  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while TempListing.where(:pixi_id => token).exists?
    @listing.pixi_id = token
  end

  # get pixter name
  def pixter_name
    User.find_by_id(@listing.pixan_id).first_name rescue nil if @listing.pixi_post?
  end

  # remove temp pixi
  def delete_temp_pixi pid
    TempListing.destroy_all(pixi_id: pid)
  end

  # determine amount left
  def amt_left
    result = @listing.quantity - @listing.sold_count rescue 0
    result <= 0 ? 0 : result
  end

  # set csv filename
  def filename status
    status.capitalize + '_' + ResetDate::set_file_timestamp
  end

  # get site address
  def primary_address
    if @listing.any_locations?
      @listing.include_list.contacts.first.full_address rescue @listing.site_name
    else
      @listing.user.primary_address if @listing.sold_by_business?
    end
  end

  # get wanted list by user
  def wanted_list usr, cid, loc, adminFlg
    result = select_fields('pixi_wants.updated_at').active.joins(:pixi_wants)
    if adminFlg
      result.where("pixi_wants.user_id is not null AND pixi_wants.status = ?", 'active').get_by_city(cid, loc, true)
    else
      result.where("pixi_wants.user_id = ? AND pixi_wants.status = ?", usr.id, 'active')
    end
  end

  # select date provided (field_name)
  def select_fields field_name
    Listing.select("listings.*, #{field_name} AS created_date").reorder("created_date DESC")
  end
end
