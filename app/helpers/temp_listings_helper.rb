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
  def step_count listing
    listing.free? ? 2 : !listing.new_status? ? 2 : 3 rescue 2
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

  # check if post is by seller 
  def seller_post?
    !@user.is_support? && action_name != 'edit' && @ptype.blank?
  end

  # check if new pixi post
  def new_pixi_post? listing
    listing.pixi_post? && !listing.edit?
  end

  # check if in edit mode
  def edit_mode? listing
    !listing.pixi_post? || listing.edit?
  end

  # check if pixi is an item
  def is_item? listing, flg=true
    val = %w(employment service vehicle)
    flg ? !(listing.is_category_type? val) : (listing.is_category_type? val)
  end

  # check if pixi has quantity
  def has_qty? listing
    listing.is_category_type? %w(employment service vehicle)
  end

  # check if pixi is chargeable
  def chargeable? listing
    listing.seller?(@user) && listing.new_status? 
  end

  # toggle element on image slider
  def set_element flg
    controller_name != 'temp_listings' ? flg ? 'large' : 'Pin it @ Pinterest' : ''
  end
end
