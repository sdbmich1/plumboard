module SessionsHelper

  def show_pwd_fld fld, str=[]
    if devise_mapping.recoverable? && controller_name != 'passwords'
      str << link_to("Forgot password?", new_password_path(fld), class: 'terms-link')
      str << "<br />"
      content_tag(:div, str.join("").html_safe) 
    end
  end

  def show_remember_me f, rmbrFlg
    if rmbrFlg && devise_mapping.rememberable?
      render partial: 'shared/signin_form_chkbox', locals: {f:f}
    else
      render partial: 'shared/signin_footer'
    end
  end

  def render_session_header
    render partial: 'layouts/header' if @xhr
  end
end
