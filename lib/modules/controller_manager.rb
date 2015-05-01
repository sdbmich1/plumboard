module ControllerManager

  # moves guest data to active user
  def self.transfer_guest_acct session, usr
    if session[:guest_user_id]
      guest = User.find(session[:guest_user_id]) rescue nil
      guest.move_to(usr) if guest && usr
      session[:guest_user_id] = nil
    end
  end

  # set default root path
  def self.set_root_path cat, region
    routes = Rails.application.routes.url_helpers
    local_url, cat_url = routes.local_listings_path(loc: region), routes.categories_path(loc: region)
    Listing.has_enough_pixis?(cat, region) ? cat_url : local_url
  end

  # set session user id
  def self.set_uid session, model, fld='user_id'
    session[:guest_user_id] = model.send(fld) if model.user.guest?
  end
end
