module PagesHelper

  # get leader points
  def get_points val
    PointManager::get_points val
  end

  # check if home page
  def home_page?
    controller_name == 'pages' && action_name == 'home' ? true : false
  end
end
