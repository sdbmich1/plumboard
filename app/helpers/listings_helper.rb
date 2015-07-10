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
	  "#{searches_path page: @listings.next_page, search: params[:search], loc: params[:loc], cid: params[:cid]}" 
	else
          "#{listings_path page: @listings.next_page}"
	end
      when "category"
        "#{category_listings_path page: @listings.next_page, loc: params[:loc], cid: params[:cid]}"
      when "local"
        "#{local_listings_path page: @listings.next_page, loc: params[:loc]}"
      when "biz"
        "#{biz_path page: @listings.next_page, url: params[:url]}"
      when "member"
        "#{member_path page: @listings.next_page, url: params[:url]}"
      when "career"
        "#{career_path page: @listings.next_page, url: params[:url]}"
      else
        "#{listings_path page: @listings.next_page}"
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
      when 'biz'
        'biz_next_page'
      when 'member'
        'member_next_page'
      when 'career'
        'career_next_page'
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
      when 'biz'
        "/biz?page="
      when 'member'
        "/member?page="
      when 'career'
        "/career?page="
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
    case Rails.env
    when 'test', 'development'
      "localhost:3000"
    when 'demo'
      "demo.pixiboard.com"
    when 'staging'
      "test.pixiboard.com"
    else
      PIXI_WEB_SITE
    end
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
    "&description=Check out this pixi on Pixiboard! " + listing.nice_title(false)
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
    '&picture=' + get_photo(listing) + '&name=' + listing.nice_title(false) + '&description=' + listing.description
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

  def cache_key_for_pixi
    "#{controller_name}-#{action_name}"
  end

  # get region for show pixi display menu
  def get_current_region listing
    if listing
      loc, loc_name = LocationManager::get_region listing.latlng rescue [@loc, @loc_name]
      link_to loc_name, category_listings_path(cid: listing.category_id, loc: loc)
    end
  end

  # check model type
  def temp_listing? model
    model.respond_to? :car_id
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
    !flg ? 'featured-item' : (controller_name == 'pages' && action_name == 'home') ? 'home-item' : 'item'
  end

  # set top banner image
  def set_banner btype
    btype == 'loc' ? set_loc_banner : set_biz_banner
  end
  
  def get_usr
    User.find_by_url @url rescue nil
  end

  def get_seller_name
    get_usr.name.html_safe rescue 'Pixis'
  end

  def set_biz_banner
    usr = get_usr
    content_tag(:div, render(partial: 'shared/user_band', locals: {user: usr, pxFlg: false, colorFlg: false}), class: ["mneg-top", "mbot"]) if usr
  end

  def set_loc_banner
    site = Site.find @loc rescue nil
    content_tag(:div, render(partial: 'shared/location_band', locals: {site: site}), class: ["mneg-top", "mbot"]) if site
  end

  # show menu if location page
  def set_pixi_menu btype, menu_name, loc_name
    render partial: 'shared/navbar', locals: { menu_name: menu_name, loc_name: @loc_name } if btype == 'loc' 
  end

  # set status type
  def show_status_menu val, sFlg
    render(partial: 'shared/status_menu', locals: { val: val }) if sFlg
  end

  def show_menu_fields ptype
    render partial: 'shared/menu_fields', locals: { ptype: ptype } if @url.blank?
  end

  # check ownership
  def is_owner?(usr)
    usr.id == @user.id rescue false
  end

  def has_featured_pixis? model
    model.size >= MIN_FEATURED_PIXIS rescue false
  end

  def has_featured_users?
    @sellers.size >= MIN_FEATURED_USERS rescue false
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
    cnt = val < MIN_FEATURED_PIXIS ? MIN_FEATURED_PIXIS : MIN_FEATURED_PIXIS*2 
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
    link_to path, class: 'img-btn' do
      render partial: 'shared/show_picture', locals: {model: model, psize: pix_size}
    end 
  end

  # toggle button
  def toggle_follow_btn seller, favorite
    if favorite && favorite.status != 'removed'
      button_to('Unfollow', favorite_seller_path(id: favorite.id, seller_id: seller.id),
          :method => :put, id: 'unfollow-btn', class: 'btn btn-primary font-bold span2', remote: true)
    else
      button_to('Follow', favorite_sellers_path(seller_id: seller.id),
          id: 'follow-btn', class: 'btn btn-primary submit-btn span2', remote: true)
    end
  end

  # show edit cover icon for owner
  def show_edit_cover_icon usr
    if is_owner?(usr)
      link_to image_tag('rsz_photo_camera.png', class: 'camera'), edit_user_path(@user), title: 'Change Cover Photo', class: 'img-btn' 
    else
      link_to image_tag('pxb_map_icon.png', class: 'camera'), '#mapDialog', title: 'View Map', 'data-toggle'=>"modal", id: 'map_icon', 
        class: 'img-btn' if usr.is_business? && usr.has_address? && controller_name != 'users'
    end
  end

  # show map title
  def show_map_title model, flg
    content_tag(:div, map_loc(model), class:'center-wrapper sm-bot black-section-title') if flg
  end

  # show map if business
  def show_map_modal usr
    render partial: 'shared/map_modal', locals: { model: usr } if usr.is_business? && usr.has_address?
  end

  # show repost btn
  def show_repost_button listing
    if repost? listing
      link_to "Repost!", repost_listing_path(listing), method: :put, class: "btn btn-large btn-primary submit-btn", id: 'px-repost-btn' 
    end
  end

  # check pixi is owned or inactive
  def owned_or_inactive? listing
    !listing.active? || listing.seller?(@user)
  end

  # set arrow for pixi details
  def arrow_img
    image_tag('pxb_features_arrow.png', class: 'farrow')
  end

  # show feature content for pixi
  def show_content txt
    content_tag(:div, arrow_img + ' ' + content_tag(:span, txt), class: 'v-align')
  end

  # process pixi feature content
  def process_content arr, cls='med-top', str=[]
    arr.map { |item| str << show_content(item) }
    content_tag(:div, str.join("").html_safe, class: cls + ' black-txt')
  end

  # display listing fields
  def show_top_fields item, str=[]
    str << "Condition: #{item.condition}" if is_item?(item) && item.condition
    str << "Color: #{item.color[0..29]}" unless item.color.blank?
    str << "Amount Left: #{get_item_amt(item)}" if item_available?(item, true, 'quantity')
    process_content str
  end

  def show_job_fields item
    process_content ["Job Type: #{item.job_type_name}", "Compensation: #{item.compensation}"] if item.job?
  end

  def show_event_fields item, str=[]
    if item.event?
      str << "Event Type: #{item.event_type_descr}"
      str << "Date(s): #{short_date item.event_start_date} - #{short_date item.event_end_date}"
      str << "Time(s): #{short_time item.event_start_time} - #{short_time item.event_end_time}"
      process_content str, ''
    end
  end

  def show_product_fields listing, str=[]
    if listing.is_category_type?('product')
      str << "Size: #{listing.item_size}" unless listing.item_size.blank?
      str << "Product Code: #{listing.other_id}" unless listing.other_id.blank?
      process_content str
    end 
  end

  def show_item_fields listing, str=[]
    if listing.is_category_type?('item')
      str << "Size: #{listing.item_size}" unless listing.item_size.blank?
      str << "Amount Left: #{get_item_amt(listing)}" 
      process_content str
    end 
  end

  def show_vehicle_fields listing, str=[]
    if listing.is_category_type?('vehicle')
      str << "Year: #{listing.year_built}" if has_year?(listing)
      str << "VIN #: #{listing.other_id}" if listing.other_id
      str << "Mileage: #{number_with_delimiter(listing.mileage)}" if listing.mileage
      process_content str
    end
  end

  def show_housing_fields listing, str=[]
    if listing.is_category_type?('housing')
      str << "Beds: #{listing.bed_no}" unless listing.bed_no.blank?
      str << "Baths: #{listing.bath_no}" unless listing.bath_no.blank?
      str << "Size: #{listing.item_size}" unless listing.item_size.blank?
      process_content str
    end 
  end

  def more_housing_fields listing, str=[]
    if listing.is_category_type?('housing')
      str << "Available: #{short_date listing.avail_date}"
      str << "Term: #{listing.term}" unless listing.term.blank?
      str << "Amount Left: #{get_item_amt(listing)}" 
      process_content str
    end 
  end

  # set thumbnails
  def set_pager model, i=0, images=[]
    model.pictures.each do |pic| 
      images << link_to(image_tag(get_pixi_image(pic, 'small'), class: 'pager-photo'), '#', 'data-slide-index'=>"#{i}") if pic.photo?
      i+=1
    end
    content_tag(:span, images.join(" ").html_safe)
  end

  # show panel buttons when active for buyers
  def show_listing_panel listing
    unless !listing.active? || listing.seller?(@user)
      content_tag(:div, render(partial: 'shared/listing_panel', locals: {listing: listing}), class: 'mleft10')
    end
  end

  def show_metric_panel listing
    content_tag(:div, render(partial: 'shared/metric_panel', locals: {listing: listing}), class: 'mleft10') if show_metric_panel? listing
  end

  def add_comments listing, str=[]
    unless signed_in? && listing.active?
      show_comment_btn listing
    else
      render partial: "#{get_comment_form}", locals: {listing: listing} unless owned_or_inactive? listing
    end
  end

  # show comment button
  def show_comment_btn listing, str=[]
    img = image_tag('rsz_plus-blue.png', class: 'v-align social-img mleft10')
    str << content_tag(:span, 'Add Comment', class: 'black-txt v-align')
    str << link_to(img, comments_path, class: 'pixi-link', remote: true, title: 'Add Comment', id: 'add-comment-btn')
    content_tag(:div, str.join(" ").html_safe, class: 'mtop')
  end

  # sets class for correct top spacing for comment list
  def set_comment_list_top listing
    owned_or_inactive?(listing) ? 'sm-top' : 'med-neg-top' 
  end

  # toggle tabs based on model
  def set_tab_headers listing, str=[]
    str << content_tag(:li, link_to('Details', '#details', 'data-toggle'=>'tab', id: 'detail-tab'), class: 'active')
    str << content_tag(:li, link_to("#{get_comment_header}", '#comments', 'data-toggle'=>'tab', id: 'comment-tab')) unless temp_listing?(listing)
    str << content_tag(:li, link_to("Map", '#map', 'data-toggle'=>'tab', id: 'map-tab')) if has_locations?(listing) && !temp_listing?(listing)
    content_tag(:ul, str.join(" ").html_safe, class: "width-all nav nav-tabs black-txt", id: 'pxTab')
  end

  # show comments if active listing
  def show_comments listing
    render(partial: 'shared/comments', locals: {listing: listing}) unless temp_listing?(listing)
  end

  def show_listing_nav listing
    check_pending_pixi listing if signed_in?
  end

  def listing_nav listing
    render(partial: 'shared/review_nav', locals: { listing: listing }) if signed_in? && listing.editable?(@user) && !pending_listings?
  end

  def temp_listing_nav listing, edit_mode
    render(partial: 'shared/show_temp_listing', locals: {listing: listing}) if signed_in? && edit_mode && !pending_listings?
  end

  def show_listing_title listing, flg
    listing.nice_title flg if listing
  end

  def show_listing listing, flg
    render partial: 'shared/view_listing', locals: {listing: listing, edit_mode: flg} if listing
  end

  def get_header_cls listing
    temp_listing?(listing) ? 'med-top' : 'ng-top'
  end

  def show_images listing, fname, sz
    render partial: 'shared/photos', locals: {model: listing, file_name: fname, psize: '120x120'} if listing
  end

  def show_social_links listing
    render partial: 'shared/social_links', locals: {listing: listing} unless temp_listing?(listing)
  end

  def show_slide pic
    content_tag(:div, image_tag(set_element(pic), class: 'lazy lrg_pic_frame', title: set_image_title, lazy: true), class:'slide') if pic.photo?
  end

  # define nav menu on show listing page
  def show_listing_menu listing, str=[]
    if listing
      str << content_tag(:li, get_current_region(listing))
      str << content_tag(:span, '|', class: 'divider')
      str << content_tag(:li, link_to(listing.site_name, category_listings_path(cid: listing.category_id, loc: listing.site_id))) 
      str << content_tag(:span, '|', class: 'divider')
      str << content_tag(:li, listing.category_name, class: 'med-top mleft10')
      content_tag(:ul, str.join(" ").html_safe, class: "nav")
    end
  end
  
  # check for locations
  def has_locations? listing
    listing.any_locations? || (listing.sold_by_business? && listing.seller_address?)
  end

  # render want content
  def wanted_content str=[]
    str << image_tag('rsz_check-mark-md.png', class: 'checkmark')
    str << content_tag(:span, 'Want', class: 'mleft5 black-txt')
    content_tag(:div, str.join(" ").html_safe, class: 'width80 left-form')
  end

  # render wanted listing content
  def wanted_listing listing, want_msg, cls
    listing.user_wanted?(@user) ? wanted_content : toggle_action_btn(listing, want_msg, cls, 'want')
  end

  # display want button
  def toggle_action_btn listing, msg, cls, atype
    unless signed_in?
      link_to atype.titleize, send("set_#{atype}_path", listing.pixi_id), method: 'post', class: cls, id: send("set_#{atype}_id"), remote: !signed_in?, 
        title: msg
    else
      render partial: "shared/show_listing_#{atype}", locals: {listing: listing, msg: msg, cls: cls}
    end
  end

  # show all pixis if not empty
  def show_listings model
    unless model.blank?
      render partial: 'shared/listing', collection: model, as: :listing, locals: {px_size: 'large', ftrFlg: true}
    else
      content_tag(:div, NO_PIXI_FOUND_MSG, class:'width240 center-wrapper')
    end
  end

  # display 'Buyer Name' if sold
  def toggle_buyer_name_header status
    content_tag(:th, 'Buyer Name') if status == 'sold'
  end

  # display name of buyer if sold
  def toggle_buyer_name_row status, listing
    name = listing.invoices.first.buyer_name rescue ''
    content_tag(:td, name, class: 'span2') if status == 'sold'
  end

  def show_recent_link rFlg
    content_tag(:li, link_to("Recent", '#', id: 'recent-link', class: 'submenu'), id: 'li_home', class: 'active') if rFlg
  end

  # assign header of date column
  def set_date_column status
    status == "draft" || status.blank? ? "Last Updated" : "#{status.titleize} Date"
  end

  # assign row of date column
  def set_date_field listing, status
    case status
    when "sold", "purchased", "wanted", "saved"; listing.created_date
    else; listing.updated_at
    end
  end
end
