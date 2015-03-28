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
    item = action_name == 'home' ? 'shared/home_page_footer' : 'shared/main_footer'
    render item
  end
end
