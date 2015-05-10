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
    pixis.map { |x| ary << x.site.contacts[0].full_address if x.site && x.site.contacts[0] }

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

  # set path based on signed in status
  def set_ask_path pid
    signed_in? ? '#' : conversations_path(id: pid)
  end

  # set want id based on signed in status
  def set_want_id
    signed_in? ? 'want-btn' : ''
  end

  # set want id based on signed in status
  def set_ask_id
    signed_in? ? 'ask-btn' : ''
  end

  # set want message
  def want_msg
    PIXI_WANT_MSG rescue 'I want this!'
  end

  # set want message
  def ask_msg
    PIXI_ASK_MSG rescue 'Ask Question'
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
      when "active"; listings_path(status: 'active', loc: loc, cid: cid, format: 'csv')
      when "expired"; listings_path(status: 'expired', loc: loc, cid: cid, format: 'csv')
      when "sold"; listings_path(status: 'sold', loc: loc, cid: cid, format: 'csv')
      when "removed"; listings_path(status: 'removed', loc: loc, cid: cid, format: 'csv')
      when "denied"; pending_listings_path(status: 'denied', loc: loc, cid: cid, format: 'csv')
      when "invoiced"; invoiced_listings_path(status: 'invoiced', loc: loc, cid: cid, format: 'csv')
      when "wanted"; wanted_listings_path(status: 'wanted', loc: loc, cid: cid, format: 'csv')
    end
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

  # get amount based on status
  def get_item_amt listing
    listing.active? ? listing.amt_left : listing.quantity
  end

  # check item status
  def item_available? listing, flg, method
    is_item?(listing, flg) && listing.send(method) && !listing.sold?
  end

  # check if want msg
  def is_want? mtype
    mtype == 'want'
  end
  
  # check if qty > 1 for wanted pixis
  def multi_qty? listing
    get_item_amt(listing) > 1
  end

  # set title based on price
  def set_title listing
    amt = listing.job? ? listing.compensation : ntc(listing.price)
    [listing.nice_title, amt].join('')
  end

  # set pixi title based on job
  def set_pixi_details listing
    listing.job? ? listing.job_type_name : ntc(listing.price, true)
  end

  # set item title based on controller
  def item_title listing, flg=true
    controller_name == 'pages' || !flg ? listing.short_title(false, 16) : listing.nice_title(false)
  end

  # toggle category title based on controller
  def item_category listing
    if controller_name == 'pages'
      listing.category_name
    else
      link_to listing.category_name, '#', class: 'pixi-cat', 'data-cat-id'=> listing.category_id
    end
  end

  # render footer if needed
  def pixi_footer listing
    render partial: 'shared/pixi_footer', locals: {listing: listing} # unless controller_name == 'pages'
  end
   
  # set class based on controller
  def set_item_class flg
    !flg ? 'featured-item' : controller_name == 'pages' ? 'home-item' : 'item'
  end

  # set top banner image
  def set_banner btype
    case btype
      when 'biz'
        usr = User.find_by_url @url rescue nil
        content_tag(:div, render(partial: 'shared/user_band', locals: {user: usr, pxFlg: false}), class: ["mneg-top", "mbot"]) if usr
      when 'loc'
        site = Site.find @loc rescue nil
        content_tag(:div, render(partial: 'shared/location_band', locals: {site: site}), class: ["mneg-top", "mbot"]) if site
      else
    end
  end

  # check ownership
  def is_owner?(usr)
    usr.id == @user.id
  end

  def has_featured_pixis? model
    model.size >= MIN_FEATURED_PIXIS
  end

  def has_featured_users?
    @sellers.size >= MIN_FEATURED_USERS
  end

  # display featured items/sellers based on band type
  def set_featured_banner model, btype
    case btype
      when 'biz'
        content_tag(:div, render(partial: 'shared/pixi_band'), class: ["mneg-top", "mbot"]) if has_featured_pixis?(model)
      when 'loc'
        content_tag(:div, render(partial: 'shared/seller_band'), class: ["mneg-top", "mbot"]) if has_featured_users?
    end
  end

  # check if manage pixis
  def show_loc_name loc_name
    action_name == 'index' ? loc_name : ''
  end

  # display featured pixis
  def featured_pixis model
    val = model.size/2
    cnt = val < MIN_FEATURED_PIXIS*2 ? val : MIN_FEATURED_PIXIS*2 
    return model[0..cnt-1]
  end

  # pixi title
  def render_title model
    content_tag(:span, model.site_name, class: "loc-descr") 
  end

  # display correct image based on model type
  def show_view_image model, pix_size, img_size
    if temp_listing?(model) 
      render partial: 'shared/show_photo', locals: {model: model, psize: '180x180', file_name: img_size, display_cnt: 0}
    else
      view_pixi_image model, pix_size, (model.is_a?(User) ? model.local_user_path : listing_path(model))
    end
  end

  def view_pixi_image model, pix_size, path
    link_to path do
      render partial: 'shared/show_picture', locals: {model: model, psize: pix_size}
    end 
  end

  # show follow button if business
  def follow_button usr
    if usr.is_business? && controller_name != 'users'
      link_to('+ Follow', '#', id: 'follow-btn', class: 'sm-top no-left span2 btn btn-primary submit-btn') unless is_owner?(usr) 
    end
  end

  # show edit cover icon for owner
  def show_edit_cover_icon usr
    link_to image_tag('rsz_photo_camera.png', class: 'camera'), edit_user_path(@user), title: 'Change Cover Photo' if is_owner?(usr)
  end

  # show repost btn
  def show_repost_button listing
    if repost? listing
      link_to "Repost!", repost_listing_path(listing), method: :put, class: "btn btn-large btn-primary submit-btn", id: 'px-repost-btn' 
    end
  end
end
