class PageFacade
  include LocationManager
  attr_reader :page

  def initialize *args
    @site = LocationManager::get_region args[0]
    @region, @loc_name = [site.id, site.name]
  end

  def listings
    Listing.active.board_fields.paginate(page: 1, per_page: PIXI_DISPLAY_AMT)
  end

  def faqs
    Faq.active
  end

  def region
    @region
  end

  def loc_name
    @loc_name
  end

  def site
    @site
  end

end
