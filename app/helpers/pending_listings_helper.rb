module PendingListingsHelper
  include ProcessMethod

  # set absolute url for current pending pixi
  def get_pending_listing_url
    ProcessMethod.get_url @listing, 'pending_listing'
  end
end
