class TempListingFacade < AppFacade
  attr_reader :listing

  def listings
    @listings.paginate(page: params[:page], per_page: 15)
  end

  def unposted_listings user
    @listings = TempListing.draft.get_by_seller(user, 'new|edit', adminFlg)
  end

  def pending_listings user
    @listings = TempListing.get_by_status('pending').get_by_seller(user, 'pending', adminFlg)
  end

  def index_listings
    @listings = TempListing.check_category_and_location(status, cat, loc, false)
  end

  def edit_listing
    @listing = TempListing.find_by_pixi_id(params[:id]) || Listing.find_by_pixi_id(params[:id]).dup_pixi(false)
  end

  def new_listing
    @listing = TempListing.new(site_id: params[:loc], pixan_id: params[:pixan_id])
  end

  def add_listing user
    @listing = TempListing.add_listing params[:temp_listing], user
  end

  def load_pixi
    @listing = TempListing.find_by_pixi_id(params[:id])
  end

  def listing
    @listing
  end

end

