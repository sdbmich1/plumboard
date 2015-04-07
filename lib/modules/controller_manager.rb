module ControllerManager

  # moves guest data to active user
  def self.transfer_guest_acct session, usr
    if session[:guest_user_id]
      Rails.logger.info "PXB Guest User ID = #{session[:guest_user_id]}"
      Rails.logger.info "PXB User ID = #{usr.id}"
      guest = User.find(session[:guest_user_id]) rescue nil
      user = User.find(usr.id) rescue nil
      guest.move_to(user) if guest && user
      session[:guest_user_id] = nil
    end
  end

  def self.set_root_path cat, region
    routes = Rails.application.routes.url_helpers
    local_url = routes.local_listings_path(loc: region)
    cat_url = routes.categories_path(loc: region)
    Listing.has_enough_pixis?(cat, region) ? cat_url : local_url
  end
end
