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

  def has_facebook_photo?
    @facebook_user.blank? ? false : !@facebook_user.picture.blank?
  end  

  def has_user_photo?
    current_user.pictures
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
      when 'listings'; render 'shared/search'
      when 'users'; render 'shared/search_users'
      when 'pending_listings'; render 'shared/search_pending'
      else render 'shared/search'
    end
  end

  # truncate timestamp in words
  def ts_in_words tm
    time_ago_in_words(tm).gsub('about','') + ' ago'
  end

  # get number of unread messages for user
  def get_unread_count(usr)
    Post.unread_count usr
  end

  # set pixi logo home path
  def pixi_home
    link_to_unless(signed_in?, "Pixiboard", root_path, id: "logo") do
      link_to 'Pixiboard', listings_path, id: "logo"
    end
  end

  # set image
  def get_image model, file_name
    !model.any_pix? ? file_name : model.pictures[0].photo.url
  end

  # return sites based on pixi type
  def get_sites ptype
    ptype ? Site.with_new_pixis : Site.with_pixis
  end

  # set display date 
  def get_local_date(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y')
  end

  # set appropriate submenu nav bar
  def set_submenu *args
    case args[0]
      when 'Invoices'; render partial: 'shared/navbar_invoices', locals: { active: 'sent' }
      when 'My Invoices'; render partial: 'shared/navbar_invoices', locals: { active: 'create' }
      when 'Categories'; render 'shared/navbar_categories'
      when 'Pixis'; render 'shared/navbar_pixis'
      when 'My Pixis'; render 'shared/navbar_mypixis'
      when 'Pending Orders'; render 'shared/navbar_pending'
      when 'Posts'; render 'shared/navbar_posts'
      else render 'shared/navbar_main'
    end
  end
  
  # build array for quantity selection dropdown
  def get_ary
    (1..99).inject([]){|x,y| x << y}
  end
end
