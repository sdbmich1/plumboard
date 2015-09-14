module PagesHelper
  include PointManager, ResetDate

  # get leader points
  def get_points val
    PointManager::get_points val
  end

  # get days left
  def get_days_left
    ResetDate::days_left
  end

  # check for days left
  def days_left?
    get_days_left.to_i > 0 rescue false
  end

  # check if home page
  def home_page?
    controller_name == 'pages' && %w(home location_name).detect {|x| action_name == x} ? true : false
  end

  # check for modal source
  def is_modal? src
    src == 'modal' ? 'mleft30 span4' : ''
  end

  # set home page tag groups
  def get_tags
    [['pxb', 'PXB'], ['ind', 'Individuals'], ['bus', 'Businesses'], ['grp', 'Peer Groups']]
  end

  # render footer based on action
  def toggle_footer
    unless signed_in?
      item = action_name == 'home' ? 'shared/home_page_footer' : 'shared/main_footer'
      render item
    end
  end

  # set class for signup form
  def signup_class src
    src == 'modal' ? 'span4' : 'offset1 span4'
  end

  # header menu
  def set_home_menu str=[]
    str << link_to('Browse', set_home_path, id: 'white-browse-home', class: "white-browse-link") if home_page? 
    str << link_to('How It Works', howitworks_path, class: 'mleft20 white-browse-link') unless action_name == 'howitworks' 
    str << link_to('Help', help_path, class: 'mleft20 white-browse-link') 
    add_signup_link str, 'mleft20 white-browse-link' 
    content_tag(:div, str.join(" ").html_safe)
  end

  def add_signup_link str, cls
    str << link_to('Login', "#loginDialog", "data-toggle" => "modal", class: cls) if !signed_in? 
    str << link_to("Signup", "#signupDialog", "data-toggle" => "modal", :class => 'mleft20 ng-top btn btn-primary pixi-btn width80') if !signed_in? 
    str
  end
end
