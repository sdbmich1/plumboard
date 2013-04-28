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
    end
  end
end
