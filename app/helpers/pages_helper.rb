module PagesHelper

  # get leader points
  def get_points val
    PointManager::get_points val
  end
end
