module RegistrationsHelper
  
  # set partial based on param
  def set_signup_partial val
    val == 'new' ? 'shared/signup_form_footer' : 'shared/signup_modal_footer'
  end
end
