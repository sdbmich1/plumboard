class ListingQueryProcessor
  include Area, ResetDate, LocationManager, NameParse, ProcessMethod

  def initialize listing
    @listing = listing
  end
  
  def prox ip, range, loc, flg
    Contact.proximity(ip, range, loc, flg)
  end

  def get_sites city, state
    Contact.get_sites(city, state)
  end

  def get_states state
    Contact.uniq.where(state: state).pluck(:contactable_id)
  end

  def get_cnty country
    Contact.uniq.where(country: country).pluck(:contactable_id)
  end

  def set_sid_params cid, sid
    unless sid.blank?
      fld, val = "category_id = :id AND site_id in (:sid)", {id: cid, sid: sid}
    else
      fld, val = "category_id = :id", {id: cid}
    end
    return fld, val
  end

  def set_params cid, sid
    unless cid.blank?
      fld, val = set_sid_params cid, sid
    else
      fld, val = "site_id in (:sid)", {sid: sid}
    end
    return fld, val
  end

  def get_data flg, params
    flg ? Listing.where(params) : TempListing.where(params)
  end

  def exec_query flg, params
    flg ? Listing.active.where(params) : get_data(flg, params)
  end

  # paginate
  def active_page ip, pg, range
    Rails.env.development? ? Listing.active.set_page(pg) : Listing.active.where(site_id: prox(ip, range, nil, false)).set_page(pg)
  end

  # get active pixis by region
  def active_by_region city, state, flg, cid, range=100
    loc = [city, state].join(', ') if city && state
    exec_query(flg, set_params(cid, prox(nil, range, loc, true))) if loc
  end

  # get active pixis by city
  def active_by_city city, state, flg, cid
    exec_query(flg, set_params(cid, get_sites(city, state)))
  end

  # get active pixis by state
  def active_by_state state, flg, cid
    exec_query(flg, set_params(cid, get_states(state)))
  end

  # get pixis by category id
  def get_by_category cid, flg
    exec_query(flg, set_params(cid, nil))
  end

  # get active pixis by country
  def active_by_country c, flg, cid
    exec_query(flg, set_params(cid, get_cnty(c)))
  end

  # get active pixis by site id
  def get_by_site sid, flg
    exec_query(flg, set_params(nil, sid))
  end

  # get pixis by category & site ids
  def get_category_by_site cid, sid, flg
    sid.blank? ? get_by_category(cid, flg) : exec_query(flg, set_params(cid, sid))
  end

  # check site's org_type and call the corresponding active_by method, or get pixis by ids if this fails
  def get_by_city cid, sid, get_active
    if (loc = Site.check_site(sid, 'city')) && !loc.contacts.blank?
      active_by_city(loc.contacts[0].city, loc.contacts[0].state, get_active, cid)
    elsif (loc = Site.check_site(sid, 'region')) && !loc.contacts.blank?
      active_by_region(loc.contacts[0].city, loc.contacts[0].state, get_active, cid)
    elsif (loc = Site.check_site(sid, 'state')) && !loc.contacts.blank?
      active_by_state(loc.contacts[0].state, get_active, cid)
    elsif (loc = Site.check_site(sid, 'country')) && !loc.contacts.blank?
      active_by_country(loc.contacts[0].country, get_active, cid)
    else
      cid.blank? ? get_by_site(sid, get_active) : get_category_by_site(cid, sid, get_active)
    end
  end

  # get wanted list by user
  def wanted_list usr, cid, loc, adminFlg
    if adminFlg
      Listing.active.joins(:pixi_wants).where("pixi_wants.user_id is not null AND pixi_wants.status = ?", 'active').get_by_city(cid, loc, true)
    else
      Listing.active.joins(:pixi_wants).where("pixi_wants.user_id = ? AND pixi_wants.status = ?", usr.id, 'active')
    end
  end

  # find all listings where a given user is the seller, or all listings if the user is an admin
  def get_by_seller user, adminFlg=true
    return nil if user.blank?
    model = @listing.respond_to?(:car_color) ? 'temp_listings' : 'listings'
    query = user.is_admin? && adminFlg ? "#{model}.seller_id IS NOT NULL" : "#{model}.seller_id = #{user.id}"
    toggle_query @listing.respond_to?(:car_color), model, query
  end

  def get_by_status val
    val == 'sold' ? Listing.sold_list : get_unsold(val)
  end

  def is_temp? val
    !%w(pending new edit).detect {|x| x == val}.nil? 
  end

  def toggle_query flg, model, query
    data = flg ? TempListing.include_list.where(query) : Listing.include_list.where(query) 
    data.order("#{model}.updated_at DESC")
  end

  def get_unsold val
    model = is_temp?(val) ? 'temp_listings' : 'listings'
    toggle_query is_temp?(val), model, "status = '#{val}'"
  end
end
