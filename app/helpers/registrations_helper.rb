module RegistrationsHelper
  
  # set partial based on param
  def set_signup_partial val
    val == 'new' ? 'shared/signup_form_footer' : 'shared/signup_modal_footer'
  end

  def show_password f, user
    if user.password_required?
      content_tag(:div, f.password_field(:password, placeholder: 'New password (min. 8 characters)', value: nil, required: true)) 
    end
  end

  def show_signup_partial f, src, id, oper
    cond = 'new'.method(oper)
    render partial: set_signup_partial(src), locals: {f: f, id: id} if cond.call(src)
  end

  def fb_login_btn title, cls, str=[]
    link_to user_omniauth_authorize_path(:facebook), id: 'fb-btn', class: cls do
      str << title 
      str << image_tag('icon_facebook.png', class: 'img-icon mleft5')
      content_tag(:span, str.join(" ").html_safe)
    end 
  end
end
