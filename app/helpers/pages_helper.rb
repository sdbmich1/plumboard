module PagesHelper

  # get leader points
  def get_points val
    PointManager::get_points val
  end

  # check if home page
  def home_page?
    controller_name == 'pages' && %w(home location_name).detect {|x| action_name == x} ? true : false
  end
end
