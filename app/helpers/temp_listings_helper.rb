module TempListingsHelper
  # set promo code for free order if appropriate
  def set_promo_code site
    PIXI_KEYS['pixi']['launch_promo_cd'] if Listing.free_order?(site)
  end
end
