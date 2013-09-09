class RegistrationsController < Devise::RegistrationsController
  layout :page_layout

  def after_sign_up_path_for(resource)
    listings_path
  end
	      
  def page_layout
    action_name == 'new' ? 'pages' : 'application'
  end
end
