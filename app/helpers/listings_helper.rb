module ListingsHelper
  include RatingManager

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
    pname = controller_name == 'searches' ? "listings" : controller_name
    ['shared', pname].join('/')
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

  # returns rating for seller
  def get_rating usr
    RatingManager::avg_rating usr
  end

  # get host
  def get_host
    host_name = Rails.env.test? || Rails.env.development? ? "localhost.com:3000" : PIXI_WEB_SITE
  end
   
  # set absolute url for current pixi
  def get_url
    Rails.application.routes.url_helpers.listing_url(@listing, :host => get_host) 
  end

  def get_photo
    'http://' + get_host + @listing.photo_url
  end

  # set string to share content on pinterest
  def pin_share
    url = "//www.pinterest.com/pin/create/button/?url=" + get_url + "&media=" + get_photo + "&description=Check out this pixi on Pixiboard!"
  end

  # set string to share content on twitter
  def tweet_share
    "https://twitter.com/share?url=https%3A%2F%2Fdev.twitter.com%2Fpages%2Ftweet-button"
  end

  # set string to share content on facebook
  def fb_share
    'https://www.facebook.com/dialog/feed?app_id=' + API_KEYS['facebook']['api_key'] + '&display=popup&caption=Check out this pixi on Pixiboard!' +
    '&link=https://developers.facebook.com/docs/reference/dialogs/&redirect_uri=' + get_url + '&picture=' + get_photo + 
    '&name=' + @listing.nice_title + '&description=' + @listing.description
  end

  # check if model is blank
  def is_blank? model
    model.blank?
  end

  # set path based on item existance and type 
  def set_item_path model, val
    pid = @listing.pixi_id rescue nil
    if val == 'like'
      !is_blank?(model) ? pixi_like_path(model, pixi_id: pid) : pixi_likes_path(id: pid)
    else
      !is_blank?(model) ? saved_listing_path(model, pixi_id: pid) : saved_listings_path(id: pid)
    end
  end

  # set method based on item existance and type 
  def set_item_method model
    method = is_blank?(model) ? 'post' : 'delete'
    method.to_sym
  end

  # set item name
  def set_item_name model, val
    if val == 'like'
      is_blank?(model) ? 'Cool' : 'Uncool'
    else
      is_blank?(model) ? 'Save' : 'Unsave'
    end
  end
end
