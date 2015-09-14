module UsersHelper
  include ProcessMethod

  # toggle boolean to string
  def toggle_bool val
    val ? 'Yes' : 'No'
  end

  # toggle menu status
  def toggle_active val, utype
    val == utype ? 'active' : ''
  end
  
  # display options based on access
  def check_access usr
    access?(usr) ? UserType.active : UserType.unhidden
  end

  # toggle visible
  def is_visible? usr, flg
    flg && usr.is_business? ? 'display:none' : ''
  end

  # show url
  def show_url? usr
    signed_in? && (access?(@user) || usr.is_business?)
  end

  # set address
  def load_address usr
    usr.has_address? ? usr.primary_address : 'None'
  end

  # toggle menu
  def set_user_menu
    @user.is_admin? ? 'Users' : 'Settings'
  end

  # toggle title
  def set_user_title
    @user.is_admin? ? @usr.name.html_safe : 'Settings' rescue 'Users'
  end

  # toggle user info form
  def set_info_form
    edit_account? ? 'shared/edit_user_info' : 'shared/user_info'
  end

  # toggle form photo title
  def get_form_photo_header mFlg
    mFlg ? 'Cover Photo' : 'Profile Photo'
  end

  # set idName
  def get_idName val
    cover_photo?(val) ? 'usr_photo2' : 'usr_photo'
  end

  # set idName
  def get_fileName val
    cover_photo?(val) ? 'photo-camera.png' : 'person_icon.jpg'
  end

  # check if cover photo
  def cover_photo? val
    !val.match(/1/).nil?
  end

  # render user tooltip based on image type
  def show_user_tooltip val
    txt = cover_photo?(val) ? 'For best results, use a 1280x200 image.' : 'For best results, use a square image (i.e. 200x200) of your photo or logo.'
    content_tag(:div, render(partial: 'shared/tooltip', locals: { msg: txt }), class: 'right-form px-neg-top')
  end

  # toggle user display text
  def render_user_details usr, flg, colorFlg
    txt = flg ? "Pixis Posted: #{usr.pixi_count}" : "#{usr.description}"
    render_txt txt, (colorFlg ? 'black-section-title' : 'white-tag-line')
  end

  def set_txt_color flg
    flg ? 'black-seller-name' : 'seller-name'
  end

  def edit_business? usr
    edit_account? && usr.is_business?
  end

  def is_biz? code, usr
    usr.is_business? || code == 'BUS'
  end

  # toggle user display name text
  def render_seller_name usr, flg
    txt = flg || controller_name == 'users' ? link_to(usr.name, usr.local_user_path, class: set_txt_color(flg)) : usr.name
    render_txt txt, set_txt_color(flg)
  end

  def render_txt txt, cls
    content_tag(:div, content_tag(:span, txt, class: cls), class: 'clear-all')
  end

  # toggle photo outline border color
  def set_profile_photo flg
    flg ? 'blk-profile-photo' : 'usr-profile-photo'
  end

  # toggle visibility based on privileges
  def show_user_row user, flg, hdr, data, str=[]
    if flg
      str << content_tag(:td, hdr, class: 'span3 field-hdr') 
      str << content_tag(:td, data)
      content_tag(:tr, str.join('').html_safe)
    end
  end

  # build dynamic cache key for seller
  def cache_key_for_seller(usr, fldName='title')
    "/#{usr.name}-#{usr.updated_at.to_i}-#{fldName}" if usr
  end

  def show_user_buttons user
    render partial: 'shared/show_user_buttons', locals: {user: user} if @user.is_admin? 
  end

  # render user specific details
  def render_user_specs model, pxFlg, colorFlg
    render partial: 'shared/user_specs', locals: {user: model, pxFlg: pxFlg, colorFlg: colorFlg}
  end

  # render user rating details
  def render_user_rating user, flg
    content_tag(:div, render(partial: 'shared/user_rating', locals: {model: user, colorFlg: flg}), id: 'rating', class: 'sm-top') if user.is_a?(User)
  end
end
