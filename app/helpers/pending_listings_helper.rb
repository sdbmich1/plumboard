module PendingListingsHelper

  # set absolute url for current pending pixi
  def get_pending_listing_url
    Rails.application.routes.url_helpers.pending_listing_url(@listing, :host => get_host)
  end

end
