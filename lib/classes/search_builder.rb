class SearchBuilder
  include LocationManager

  def initialize(cat, loc, pg, ip)
    @cat, @loc, @page = cat, loc, pg
    @lat, @lng = LocationManager::get_lat_lng ip rescue nil
  end

  # dynamically define search options based on selections
  def search_options url, sid
    url.blank? ? build_search_options(sid) : build_url_options(url, sid)
  end

  # build standard search options
  def build_search_options sid
    unless @loc.blank?
      @cat.blank? ? {:include => [:pictures, :site, :category], with: {site_id: sid}, star: true, page: @page} : 
        {:include => [:pictures, :site, :category], with: {category_id: @cat, site_id: sid}, star: true, page: @page}
    else
      unless @cat.blank?
        {:include => [:pictures, :site, :category], with: {category_id: @cat}, geo: [@lat, @lng], order: "geodist ASC, @weight DESC", 
	  star: true, page: @page}
      else
        {:include => [:pictures, :site, :category], star: true, page: @page} #, geo: [@lat, @lng], order: "geodist ASC, @weight DESC"
      end
    end
  end

  # build search w/ url
  def build_url_options url, sid
    unless @loc.blank?
      @cat.blank? ? {:include => [:pictures, :site, :category], with: {site_id: sid}, conditions: {url: url}, star: true, page: @page} : 
        {:include => [:pictures, :site, :category], with: {category_id: @cat, site_id: sid}, conditions: {url: url}, star: true, page: @page}
    else
      unless @cat.blank?
        {:include => [:pictures, :site, :category], with: {category_id: @cat}, conditions: {url: url}, geo: [@lat, @lng], 
	  order: "geodist ASC, @weight DESC", star: true, page: @page}
      else
        {:include => [:pictures, :site, :category], conditions: {url: url}, star: true, page: @page}  
      end
    end
  end
end
