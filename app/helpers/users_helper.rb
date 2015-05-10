module UsersHelper

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
    @user.is_admin? ? @usr.name : 'Settings' rescue 'Users'
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

  # toggle user display text
  def render_user_details usr, flg
    txt = flg ? "Pixis Posted: #{usr.pixi_count}" : "#{usr.description}"
    content_tag(:span, txt, class: 'pxp-tag-line')
  end

  def edit_business? usr
    edit_account? && usr.is_business?
  end
end
