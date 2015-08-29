module ApplicationHelper
  include ControllerManager, LocationManager

  # Returns the full title on a per-page basis.
  def full_title page_title
    base_title = "Pixiboard"
    page_title.empty? ? base_title : "#{base_title} | #{page_title}"
  end

  # devise settings
  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def resource_name
    devise_mapping.name
  end

  def resource_class
    devise_mapping.to
  end

  # set blank user photo based on gender
  def showphoto(gender)
    @photo = gender == "Male" ? "headshot_male.jpg" : "headshot_female.jpg"
  end

  # used to toggle breadcrumb images based on current registration step
  def bc_image(bcrumb, val, file1, file2)
    bcrumb >= val ? file1 : file2
  end

  # used do determine if search form is displayed
  def display_search
    case controller_name
      when 'categories', 'searches', 'listings', 'pending_listings'; render 'shared/search' if action_name != 'show'
      when 'posts', 'conversations'; render 'shared/search_posts'
      when 'users'; render 'shared/search_users' unless action_name == 'show'
    end
  end

  # truncate timestamp in words
  def ts_in_words tm
    time_ago_in_words(tm).gsub('about','') + ' ago' if tm
  end

  # get number of unread messages for user
  def get_unread_count(usr)
    Post.unread_count usr
  end

  # set pixi logo home path
  def pixi_home
    if mobile_device?
      link_to image_tag('sm_px_word_logo.png'), get_home_path, class: "px-logo"
    else
      link_to image_tag('px_word_logo.png'), get_home_path, class: "pixi-logo"
    end
  end

  # set home path
  def get_home_path
    signed_in? ? set_home_path : root_path
  end

  # route to my pixis page if possible
  def get_return_path
    @user.is_admin? ? listings_path(status: 'active') : @user.has_pixis? ? seller_listings_path(status: 'active') : get_home_path
  end

  # set home path based on pixi count
  def set_home_path
    ControllerManager::set_root_path @cat, @region
  end

  # set image
  def get_image model, file_name, nxtImageFlg=false
    if model
      if nxtImageFlg && model.any_pix?
        model.pictures[1].photo_file_name.nil? ? file_name : get_pixi_image(model.pictures[1], 'cover')
      else
        !model.any_pix? ? file_name : get_pixi_image(model.pictures[0])
      end
    else
      file_name
    end
  end

  # return sites based on pixi type
  def get_sites ptype
    ptype ? Site.with_new_pixis : Site.active_with_pixis
  end

  # set display date
  def get_local_date(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y') if tm
  end

  # set display time
  def get_local_time(tm)
    tm.strftime("%l:%M %p") unless tm.blank?
  end

  # parse navbar menu
  def parse_item val, item
    (val.is_a? String) ? val : val[item.to_sym]
  end

  # toggle recent menu item
  def show_recent?
    controller_name != 'searches'
  end

  # set appropriate submenu nav bar
  def set_submenu *args
    case parse_item(args[0], 'name')
      when 'Invoices'; render partial: 'shared/navbar_invoices', locals: { active: parse_item(args[0], 'action') || 'sent' }
      when 'Categories'; render 'shared/navbar_categories'
      when 'Pixis'; render partial: 'shared/navbar_pixis', locals: { loc_name: @loc_name, rFlg: show_recent?, statusFlg: false }
      when 'Pixi'; render 'shared/navbar_show_pixi'
      when 'My Pixis'; render 'shared/navbar_mypixis'
      when 'My Accounts'; render 'shared/navbar_accounts'
      when 'Pending Orders'; render 'shared/navbar_pending'
      when 'Messages'; render 'shared/navbar_conversations'
      when 'Home'; render 'shared/navbar_home', locals: { loc_name: @loc_name }
      when 'PixiPosts'; render 'shared/navbar_pixi_post'
      when 'My PixiPosts'; render 'shared/navbar_pixi_post'
      when 'Inquiries'; render 'shared/navbar_inquiry'
      when 'Users'; render 'shared/navbar_users'
      when 'Sites'; render 'shared/navbar_sites'
      when 'Manage Pixis'; render 'shared/navbar_manage_pixis'
      when 'My Sellers', 'Manage Followers', 'My Followers'; render 'shared/navbar_sellers'
      else render 'shared/navbar_main'
    end
  end
  
  # build array for quantity selection dropdown
  def get_ary val=99
    (1..val).inject([]){|x,y| x << y}
  end

  # set numeric display
  def num_display model, fld
    number_with_precision(model.send(fld), :precision=>2)
  end

  # set account path based on user has an account
  def get_account_path
    if @user.has_bank_account?
      @acct = @user.bank_accounts.first
      @acct.new_record? ? new_bank_account_path : bank_account_path(@acct)
    else
      new_bank_account_path
    end
  end

  # use bootstrap for flash messages
  def bootstrap_class_for flash_type
     case flash_type
       when :success
         "alert-success"
       when :error
         "alert-error"
       when :alert
         "alert-block"
       when :notice
         "alert-info"
       else
         flash_type.to_s
     end
  end

  # set path based on invoice count
  def get_unpaid_path pid=nil, cid=nil
    if @user.unpaid_invoice_count > 0
      @invoice = pid.blank? ? @user.unpaid_received_invoices : Invoice.get_by_status_and_pixi('unpaid', @user.id, pid)
      invoice_path(@invoice.first, cid: cid)
    end
  end

  # toggle header if str matches
  def toggle_header? title
    str = 'Pixi|Invoice|Account|Post|Setting|Order|Purchase' # set match string
    !(title.downcase =~ /^.*\b(#{str.downcase})(s){0,1}\b.*$/i).nil?
  end

  # convert to currency
  def ntc val, zeroFlg=false
    val.blank? ? '$0' : number_to_currency(val, :precision => (val.round == val) && zeroFlg ? 0 : 2) rescue nil
  end

  # convert to thousand
  def nth val
    number_to_human(val)
  end

  # check page count for infinite scroll display
  def valid_next_page? model
    model.next_page <= model.total_pages rescue nil
  end

  # check for ajax
  def remote?
    %w(check show edit new).detect {|x| x == action_name}.blank?
  end

  # set model class for pixi dropdown menu
  def set_pixi_class
    controller_name == 'pixi_posts' ? 'pixi_post'.to_sym : 'invoice'.to_sym
  end

  # get acct type for account menu
  def get_acct_type
    controller_name == 'bank_accounts' ? 'bank' : 'card'
  end

  # check pending status
  def is_pending? listing
    listing.pending? && controller_name == 'pending_listings'
  end

  # build dynamic path for cache
  def set_cache_path listing
    if controller_name == 'searches'
      'searches'
    else
      is_pending?(listing) ? 'pending_listings' : %w(new edit).detect {|x| x == listing.status}.blank? ? 'listings' : 'temp_listings'
    end
  end

  # build dynamic cache key for pixis
  def cache_key_for_pixi_item(listing, fldName='title')
    set_cache_path(listing) + "/#{listing.pixi_id}-#{listing.title}-#{listing.updated_at.to_i}-user-#{@user.id}-#{fldName}" if listing
  end

  # build dynamic cache key for pixi show page
  def cache_key_for_pixi_page(listing, fldName='title')
    set_cache_path(listing) + "/#{listing.pixi_id}-#{listing.title}-#{listing.amt_left}-#{listing.updated_at.to_i}-#{fldName}" if listing
  end

  def cache_key_for_fragment(section)
    "#{section}-#{controller_name}-#{action_name}"
  end

  # check for menu display of footer items
  def show_footer_items?
    controller_name == 'listings' && %w(index category local).detect {|x| action_name == x}
  end

  # check if using remote pix
  def use_remote_pix?
    USE_LOCAL_PIX.upcase != 'YES' rescue true
  end

  # check if image exists if not render uploaded image
  def get_pixi_image pic, size='default'
    size = get_default_size(pic.imageable_type) if size == 'default'
    if pic.photo.exists?
      pic.photo.url(size.to_sym)
    elsif use_remote_pix?
      pic.direct_upload_url
    else
      'rsz_pixi_top_logo.png'
    end
  end

  # get default size of an image
  def get_default_size(imageable_type)
    case imageable_type
    when 'Listing', 'TempListing' then 'large'
    else 'thumb'
    end
  end

  # check if image exists
  def check_image model, psize, lazy_flg=false
    img_class = lazy_flg ? 'lazy ' + zoom_image : ''
    image_tag(get_pixi_image(model.pictures[0], psize), class: img_class, lazy: lazy_flg) if picture_exists?(model)
  end

  # check for model errors
  def check_errors? model
    model.errors.any? rescue false
  end

  # check if next page exists
  def next_page? model
    model.next_page rescue false
  end

  # check if invoice exists
  def invoice_exists? invoice
    invoice && invoice.buyer rescue false
  end

  # check if picture exists
  def picture_exists? model
    model && model.pictures[0] rescue false
  end

  # set class name if not on the main board
  def zoom_image
    %w(category local).detect {|x| action_name == x} ? '' : action_name == 'home' ? 'img-board' : 'fpx-image'
  end

  # used to dynamically remove field from a given form
  def link_to_remove_fields(title, f)
    f.hidden_field(:_destroy) + 
      link_to(image_tag('rsz_minus.png', class: 'social-img mbot'), '#', confirm: 'Delete this item?', class: 'remove-row-btn pixi-link', title: title)
  end 

  # add new picture for model
  def setup_picture(model)
    model.pictures.build if model.pictures.empty? rescue nil
    return model
  end

  # select drop down for remove btn
  def button_menu model, atype
    # build content tag
    if controller_name == 'listings'
      model.remove_item_list.collect {|item| concat(content_tag(:li, link_to(item, listing_path(model, reason: item), method: :put)))}
    elsif controller_name == 'invoices'
      model.decline_item_list.collect { |item|
        concat(content_tag(:li, link_to(item, decline_invoice_path(model, reason: item), confirm: 'Decline this invoice?', method: :put)))
      }
    else
      model.deny_item_list.collect {|item| concat(content_tag(:li, link_to(item, deny_pending_listing_path(model, reason: item), method: :put)))}
    end
    return ''
  end

  # removes html tags
  def sanitize txt
    simple_format(txt, {}, sanitize: false) 
  end

  # toggle font color for rating
  def get_rating_class wFlg=true
    wFlg ? 'tiny-black' : 'tiny-white'
  end

  # toggle class for rating
  def set_rating_class flg
    flg ? 'bmed-pixis' : 'med-pixis'
  end

  # toggle class for rating
  def set_rating_val flg, hFlg=false
    hFlg ? 21 : 24
  end

  # set list tag id for photo uploader
  def get_list_id tag
    tag == 'usr_photo2' ? 'list2' : 'list'
  end

  # dynamically set background image
  def load_bkgnd model, cnt=1, locFlg=false
    img = locFlg ? "bokeh.jpg" : "gm_grey.jpg"
    return img if model.blank?
    model.pictures[cnt] ? get_pixi_image(model.pictures[cnt], 'cover') : img
  end

  # check usr access
  def access? usr
    can?(:manage_users, usr)
  end

  # set top menu navigation based on sign in status
  def top_menu
    if signed_in?
      render 'layouts/display_menu'
    else
      content_tag(:ul, content_tag(:li, link_to("Sign in", new_user_session_path)), class: "nav pull-right")
    end
  end

  # toggle menu access based on user privileges
  def show_post_for_menu str=[]
    if can? :manage_pixi_posts, @user
      str << link_to("For Seller", new_temp_listing_path(pixan_id: @user), id: 'pixi-post') 
      str << link_to("For Business", new_temp_listing_path(pixan_id: @user, ptype: 'bus'), id: 'bus-ppost')
      content_tag(:li, str.join(" ").html_safe)
    end
  end

  # toggle menu access based on user privileges
  def show_manage_menu
    render 'layouts/manage' if can? :manage_pixi_posts, @user
  end

  def show_bill_menu_btn
    content_tag(:li, link_to("Bill", get_invoice_path, id: 'bill-pixi')) if @user.has_pixis?
  end

  def show_pay_menu_btn
    content_tag(:li, link_to("Pay", get_unpaid_path, id: 'pay-pixi')) if @user.has_unpaid_invoices?
  end

  # toggle field display visible
  def set_style flg
    flg ? 'display:none' : ''
  end

  # set pagination
  def paginate_list id, model
    content_tag(:div, (will_paginate(model) if model.respond_to?(:total_pages)), id: id, class: 'nav pull-right')
  end

  def show_entries model, tag
    content_tag(:div, (page_entries_info model, :model => tag), class: 'pg-entry left-form', id: 'entry-top')
  end

  # get address for map
  def map_loc model
    model.primary_address if model.has_address?  
  end

  # return map coords if address is found
  def get_lnglat model
    LocationManager::get_google_lng_lat(model.primary_address) if model.has_address?  
  end

  # show progress meter if needed
  def show_progress_meter flg
    content_tag(:div, render(partial: 'shared/progress_meter'), class: 'mtop left-form mleft30') if flg
  end

  # set file_field
  def photo_cabinet form, s3Flg, keyName, mFlg
    if s3Flg 
      form.s3_file_field :photo, { id: keyName, multiple: mFlg, class: 'file js-s3_file_field' } 
    else 
      form.file_field :photo, { id: keyName, multiple: mFlg, class: 'file' } 
    end 
  end

  # show link if member or business
  def my_site_link
    content_tag(:li, link_to("My Site", @user.local_user_path)) if @user.is_business? || @user.is_member?
  end

  def show_border_image model, display_cnt, file_name, psize, flg
    cls = display_cnt == 0 ? file_name : 'pic-frame'
    content_tag(:div, image_tag(get_pixi_image(model.pictures[pic_no(flg)]), :size => psize, class: 'img-zoom'), class: cls)
  end

  # toggle picture selector
  def pic_no flg
    flg ? 0 : 1
  end

  def process_show_photo_image model, display_cnt, file_name, psize, flg
    if display_cnt < 2
      show_border_image model, display_cnt, file_name, psize, flg
    elsif display_cnt > 2
      image_tag(get_pixi_image(model.pictures[pic_no(flg)]), class: file_name)
    else
      render partial: 'shared/photos', locals: {model: model, psize: psize }
    end
  end

  def show_photo model, display_cnt, file_name, psize, flg=true
    process_show_photo_image model, display_cnt, file_name, psize, flg if picture_exists? model
  end

  # render list partial if data exists
  def render_list model, pname, msg, type=nil
    unless model.blank?
      render partial: pname, locals: { model: model, type: type }
    else
      content_tag(:div, msg, class: 'center-wrapper')
    end
  end
end
