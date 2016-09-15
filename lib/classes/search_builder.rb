class SearchBuilder
  include LocationManager, ProcessMethod

  def initialize(cat, loc, pg, sz, ip)
    @cat, @loc, @page, @sz = cat, loc, pg, sz
    @lat, @lng = LocationManager::get_lat_lng ip rescue nil
    @sql = ProcessMethod::get_board_flds
    @models = [:pictures, :site, :category]
  end

  # dynamically define search options based on selections
  def search_options url, sid
    hash = url.blank? ? build_search_options(sid) : build_url_options(url, sid)
    hash[:per_page] = @sz
    hash
  end

  # build standard search options
  def build_search_options sid
    unless @loc.blank?
      @cat.blank? ? {sql: {select: @sql, include: @models},  with: {site_id: sid}, star: true, page: @page, per_page: @sz} : 
        {sql: {select: @sql, :include => @models}, with: {category_id: @cat, site_id: sid}, star: true, page: @page, per_page: @sz}
    else
      unless @cat.blank?
        {sql: {select: @sql, include: @models}, with: {category_id: @cat}, geo: [@lat, @lng], order: "geodist ASC, @weight DESC", 
	  star: true, page: @page, per_page: @sz}
      else
        {sql: {select: @sql, include: @models}, star: true, page: @page, per_page: @sz} #, geo: [@lat, @lng], order: "geodist ASC, @weight DESC"
      end
    end
  end

  # build search w/ url
  def build_url_options url, sid
    unless @loc.blank?
      @cat.blank? ? {sql: {select: @sql, include: @models}, with: {site_id: sid}, conditions: {url: url}, star: true, page: @page, per_page: @sz} : 
        {sql: {select: @sql, include: @models}, with: {category_id: @cat, site_id: sid}, conditions: {url: url}, star: true, page: @page, per_page: @sz}
    else
      unless @cat.blank?
        {sql: {select: @sql, include: @models}, with: {category_id: @cat}, conditions: {url: url}, geo: [@lat, @lng], 
	  order: "geodist ASC, @weight DESC", star: true, page: @page, per_page: @sz}
      else
        {sql: {select: @sql, include: @models}, conditions: {url: url}, star: true, page: @page, per_page: @sz}  
      end
    end
  end
end
