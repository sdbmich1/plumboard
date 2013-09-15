module ListingsHelper

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

  # build location array for map display
  def build_lnglat_ary pixis
    ary = []

    # build array
    pixis.map do |x| 
      if x.site
        ary << x.site.contacts[0].full_address if x.site.contacts[0] 
      end
    end

    # flatten and return as json
    ary.flatten(1).to_json       
  end

  # check if page needs refreshing
  def refresh_page?(axn)
    (%w(show).detect { |x| x == axn })
  end

  # get board item width for masonry
  def get_item_width
    mobile_device? ? '120x120' : '150x150'
  end

  # set next page path for ajax infinite scroll call based on action name
  def set_next_page_path
    case action_name
      when 'index'
        if controller_name == 'searches'
	  '#{searches_path page: @listings.next_page, search: params[:search], loc: params[:loc], cid: params[:cid]}' 
	else
          '#{listings_path page: @listings.next_page}'
	end
      when 'category'
        '#{category_listings_path page: @listings.next_page, loc: params[:loc], cid: params[:cid]}'
      when 'location'
        "#{location_listings_path page: @listings.next_page, loc: params[:loc]}"
      else
        '#{listings_path page: @listings.next_page}'
    end
  end

  # get path name
  def get_next_path_name
    case action_name
      when 'index'
        controller_name == 'searches' ? 'search_next_page' : 'listing_next_page'
      when 'category'
        'cat_list_next_page'
      when 'location'
        'loc_list_next_page'
      else
        'listing_next_page'
    end
  end

  # set partial name
  def set_partial_name
    ['shared', 'listings'].join('/')
  end

  # set init next page path for ajax infinite scroll call based on action name
  def set_init_next_page_path
    ['shared', get_next_path_name].join('/')
  end

  # set path name for infinite scroll
  def set_path_parse
    case action_name
      when 'index'
        controller_name == 'searches' ? "/searches?page=" : '/listings?page='
      when 'category'
        "/listings/category?page="
      when 'location'
        "/listings/location?page="
      else
        '/listings?page='
    end
  end
end
