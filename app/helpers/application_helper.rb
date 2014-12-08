module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title page_title
    base_title = "Pixiboard"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
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
      when 'categories'; render 'shared/search' if action_name != 'show'
      when 'listings'; render 'shared/search' if action_name != 'show'
      when 'posts'; render 'shared/search_posts'
      when 'users'; render 'shared/search_users'
      when 'pending_listings'; render 'shared/search' if action_name != 'show'
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

  # set home path based on pixi count
  def set_home_path
    Listing.has_enough_pixis?(@cat, @region, @page) ? categories_path(loc: @region) : local_listings_path(loc: @region)
  end

  # set image
  def get_image model, file_name
    if model
      !model.any_pix? ? file_name : get_pixi_image(model.pictures[0])
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

  # set appropriate submenu nav bar
  def set_submenu *args
    case parse_item(args[0], 'name')
      when 'Invoices'; render partial: 'shared/navbar_invoices', locals: { active: parse_item(args[0], 'action') || 'sent' }
      when 'Categories'; render 'shared/navbar_categories'
      when 'Pixis'; render partial: 'shared/navbar_pixis', locals: { loc_name: @loc_name, rFlg: true, statusFlg: false }
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
      when 'Manage Pixis'; render 'shared/navbar_manage_pixis'
      else render 'shared/navbar_main'
    end
  end
  
  # build array for quantity selection dropdown
  def get_ary
    (1..99).inject([]){|x,y| x << y}
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
  def get_unpaid_path
    if @user.unpaid_invoice_count > 0
      @invoice = @user.unpaid_received_invoices.first
      invoice_path(@invoice)
    end
  end

  # toggle header if str matches
  def toggle_header? title
    str = 'Pixi|Invoice|Account|Post|Setting|Order|Purchase' # set match string
    !(title.downcase =~ /^.*\b(#{str.downcase})(s){0,1}\b.*$/i).nil?
  end

  # convert to currency
  def ntc val, zeroFlg=false
    val.blank? ? '' : number_to_currency(val, :precision => (val.round == val) && zeroFlg ? 0 : 2) rescue nil
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

  # build dynamic cache key for pixi show page
  def cache_key_for_pixi_item(listing)
    path = is_pending?(listing) ? 'pending_listings' : %w(new edit).detect {|x| x == listing.status}.blank? ? 'listings' : 'temp_listings'
    path + "/#{listing.pixi_id}-#{listing.title}-#{listing.updated_at.to_i}-user-#{@user.id}"
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
  def get_pixi_image pic, size='original'
    pic.photo.exists? ? pic.photo.url(size.to_sym) : use_remote_pix? ? pic.picture_from_url : 'rsz_pixi_top_logo.png'
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
    %w(category local).detect {|x| action_name == x} ? '' : 'img-zoom'
  end
end
