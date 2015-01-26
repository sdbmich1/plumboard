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
end
