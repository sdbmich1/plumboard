class SiteProcessor
  include ProcessMethod

  def initialize site
    @site = site
  end

  def get_site_type
    @site.is_pub? ? 'pub' : 'edu'
  end

  # initialize data
  def set_flds
    @site.site_url = @site.name if @site.is_pub? || @site.is_school?
  end

  # create unique url for user
  def generate_url value, cnt=0
    ProcessMethod::generate_url 'Site', value, cnt
  end

  def url_str
    [ProcessMethod::get_host, '/', get_site_type, '/'].join('')
  end

  # getter for url
  def site_url 
    [url_str, @site.url].join('') rescue nil
  end

  def local_site_path
    ['/', get_site_type, '/', @site.url].join('') rescue nil
  end

  # get nearest region
  def get_nearest_region loc, range=60
    unless site = Site.where(id: Contact.proximity(nil, range, loc, true)).get_by_type('region').first
      site = Site.where(name: PIXI_LOCALE).first
    end
    [site.id, site.name] rescue [0, loc]
  end

  # select active sites w/ pixis
  def active_with_pixis
    Site.where(id: Listing.active.pluck(:site_id).uniq)
  end

end
