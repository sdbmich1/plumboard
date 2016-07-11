class ListingFacade < AppFacade
  include ControllerManager, PointManager
  attr_reader :listing

  def listing
    @listing = Listing.find_pixi params[:id]
  end

  def comments
    @comments ||= listing.comments.paginate(page: params[:page], per_page: PIXI_COMMENTS) rescue nil
  end

  def set_status
    @status.to_sym rescue :active
  end

  def board_listings
    items = Listing.load_board(cat, loc)
    load_sellers items
  end

  def load_sellers items
    @sellers = User.get_sellers(items)
    @categories = Category.get_categories(items) # unless action_name == 'category'
    @listings = items.set_page(params[:page], MIN_BOARD_AMT) rescue nil
  end

  def url_listings request, aname, homeID, user
    items = Listing.get_by_url(set_url(request, aname), aname, cat)
    load_sellers items
  end

  def set_url request, aname 
    @cat = Category.get_by_name('Jobs')
    @url = aname == 'career' ? 'Pixiboard' : ControllerManager::parse_url(request)
  end

  def sellers
    @sellers
  end

  def categories
    @categories
  end

  def listings
    case action_name
    when 'index', 'seller', 'seller_wanted', 'purchased', 'wanted', 'invoiced' 
      return @listings.paginate(page: params[:page], per_page: 15)
    else return @listings
    end
  end

  def is_active?
    status == 'active'
  end

  def index_listings
    @listings = Listing.check_category_and_location(status, cat, loc, is_active?)
  end

  def invoiced_listings
    @listings = Listing.check_invoiced_category_and_location(cat, loc)
  end

  def wanted_listings user
    @listings = Listing.wanted_list(user, cat, loc)
  end

  def seller_listings user
    @listings = Listing.get_by_status_and_seller(status, user, adminFlg)
  end

  def seller_wanted_listings user
    @listings = Listing.wanted_list(user, nil, nil, false)
  end

  def purchased_listings user
    @listings = Listing.purchased(user)
  end

  def add_points user
    PointManager::add_points user, 'vpx'
  end

  def page_layout
    ControllerManager.render_board?(action_name) ? 'listings' : action_name == 'show' ? 'pixi' : 'application'
  end

end

