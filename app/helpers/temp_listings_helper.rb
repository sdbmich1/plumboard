module TempListingsHelper

  # set promo code for free order if appropriate
  def set_promo_code site
    PIXI_KEYS['pixi']['launch_promo_cd'] if Listing.free_order?(site)
  end

  # set delete messsage for pixi
  def msg
    'Are you sure? All your changes will be lost.'
  end

  # set delete messsage for photo
  def photo_msg
    'Image will be removed. Are you sure?'
  end

  # return # of steps to submit new pixi
  def step_count
    @listing.free? ? 2 : !@listing.new_status? ? 2 : 3
  end
  
  # build array for year selection dropdown
  def get_year_ary
    (Date.today.year-99..Date.today.year).inject([]){|x,y| x << y}.reverse
  end

  # check controller name
  def pending_listings?
    controller_name == 'pending_listings'
  end

  # check if pending listing
  def check_pending_pixi listing
    path = (mobile_device? ? 'mobile' : 'shared') + '/pending_listing' 
    render partial: path, locals: {listing: listing} if pending_listings?
  end

  # set different url if pixi is pending
  def set_pixi_path listing
    listing.pending? && controller_name == 'pending_listings' ? pending_listing_url(listing) : listing
  end
end
