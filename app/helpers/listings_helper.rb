module ListingsHelper
  include RatingManager

  # format time
  def get_local_time(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y %I:%M%p') rescue nil
  end

  # format short date
  def short_date(tm)
    tm.strftime('%m/%d/%Y') rescue nil
  end

  # format short time
  def short_time tm
    tm.strftime('%I:%M%p') rescue nil
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
      when 'local'
        "#{local_listings_path page: @listings.next_page, loc: params[:loc]}"
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
      when 'local'
        controller_name == 'categories' ? 'category_next_page' : 'loc_list_next_page'
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
      when 'local'
        "/listings/local?page="
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
    (Rails.env.test? || Rails.env.development?) ? "localhost:3000" :
        ((Rails.env.staging?) ? "test.pixiboard.com" : PIXI_WEB_SITE)
  end
   
  # set absolute url for current pixi
  def get_url listing
    Rails.application.routes.url_helpers.listing_url(listing, :host => get_host) 
  end

  def get_photo listing
    listing.photo_url
  end

  # set string to share content on pinterest
  def pin_share listing
    "//www.pinterest.com/pin/create/button/?url=" + get_url(listing) + "&media=" + get_photo(listing) + 
    "&description=Check out this pixi on Pixiboard! " + listing.nice_title
  end

  # set string to share content on twitter
  def tweet_share listing
    "https://twitter.com/share?url=" + get_url(listing) # https%3A%2F%2Fdev.twitter.com%2Fpages%2Ftweet-button
  end

  # set string to share content on facebook
  def fb_share listing
    'https://www.facebook.com/dialog/feed?app_id=' + API_KEYS['facebook']['api_key'] + 
    '&display=popup&caption=Check out this pixi on Pixiboard!' +
    '&link=' + get_url(listing) + '&redirect_uri=' + get_url(listing) + 
    '&picture=' + get_photo(listing) + '&name=' + listing.nice_title + '&description=' + listing.description
  end

  # set path based on like existance and type 
  def set_like_path model, pid
    unless pid.blank?
      model.user_liked?(@user) ? pixi_like_path(model) : pixi_likes_path(id: pid)
    end
  end

  # set path based on saved existance and type 
  def set_saved_path model, pid
    unless pid.blank?
      model.user_saved?(@user) ? saved_listing_path(model) : saved_listings_path(id: pid)
    end
  end

  # set path based on signed in status
  def set_want_path pid
    signed_in? ? '#' : conversations_path(id: pid)
  end

  # set want id based on signed in status
  def set_want_id
    signed_in? ? 'want-btn' : ''
  end

  # set want message
  def want_msg
    PIXI_WANT_MSG rescue 'I want this!'
  end

  # set method based on item existance and type 
  def set_item_method model, val
    if val == 'like'
      method = model.user_liked?(@user) ? 'delete' : 'post'
    else
      method = model.user_saved?(@user) ? 'delete' : 'post'
    end
    method.to_sym
  end

  # set item name
  def set_item_name model, val
    if val == 'like'
      model.user_liked?(@user) ? 'Uncool' : 'Cool'
    else
      model.user_saved?(@user) ? 'Unsave' : 'Save'
    end
  end

  # check if panel needs to be displayed
  def show_metric_panel? model
    if controller_name == 'listings'
      (model.has_status? %w(active sold)) && model.seller?(@user)
    else
      false
    end
  end

  # set pixi poster
  def set_poster_id listing
    poster = listing.pixi_post? && !@user.is_member? ? 'pixan_id' : 'seller_id'
    poster.to_sym
  end

  # select drop down for remove btn
  def remove_menu listing
    # build content tag
    if controller_name == 'listings'
      listing.remove_item_list.collect {|item| concat(content_tag(:li, link_to(item, listing_path(listing, reason: item), method: :put)))}
    end
    return ''
  end

  # build dynamic cache key for pixi show page
  def cache_key_for_pixi_panel(listing)
    if listing
      wants, likes, saves = listing.wanted_count, listing.liked_count, listing.saved_count
      "listings/#{listing.pixi_id}-want-#{wants}-like-#{likes}-save-#{saves}-user-#{@user}"
    else
      Time.now.to_s
    end
  end

  # get region for show pixi display menu
  def get_current_region listing
    if listing
      loc, loc_name = LocationManager::get_region listing.site_name
      link_to loc_name, category_listings_path(cid: listing.category_id, loc: loc)
    end
  end

  # check model type
  def temp_listing? model
    model.is_a? TempListing
  end

  # toggle csv output based on status type
  def get_csv_path status_type, cid, loc
    case status_type
      when "pending"; pending_listings_path(status: 'pending', loc: loc, cid: cid, format: 'csv')
      when "draft"; unposted_temp_listings_path(status: 'new/edit', loc: loc, cid: cid, format: 'csv')
      when "active"; listings_path(status: 'active', loc: loc, cid: cid, format: 'csv')
      when "expired"; listings_path(status: 'expired', loc: loc, cid: cid, format: 'csv')
      when "sold"; listings_path(status: 'sold', loc: loc, cid: cid, format: 'csv')
      when "removed"; listings_path(status: 'removed', loc: loc, cid: cid, format: 'csv')
      when "denied"; listings_path(status: 'denied', loc: loc, cid: cid, format: 'csv')
      when "invoiced"; invoiced_listings_path(loc: loc, cid: cid, format: 'csv')
      when "wanted"; wanted_listings_path(loc: loc, cid: cid, format: 'csv')
    end
  end

  # toggle wanted view based on user type
  def select_wanted_view
    @user.is_admin? ? 'shared/manage_pixis' : 'shared/mypixis_list'
  end

  # check repost status
  def repost? listing
    (expired_or_sold? listing) && (@user.is_admin? || (@user.id == listing.seller_id))
  end

  # check for expired or sold status
  def expired_or_sold? listing
    listing.has_status? %w(sold expired removed)
  end

  # check for year
  def has_year? listing
    listing.has_year? && listing.year_built
  end
end
