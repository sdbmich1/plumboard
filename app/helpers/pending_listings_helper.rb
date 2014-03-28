module PendingListingsHelper

  # check for ajax
  def remote?
    action_name == 'show' ? false : true
  end
end
