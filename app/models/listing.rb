class Listing < ListingParent
  self.table_name = "listings"
  include ThinkingSphinx::Scopes

  before_create :activate
  attr_accessor :parent_pixi_id

  has_many :posts, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :invoices, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :comments, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy

  has_many :site_listings, :dependent => :destroy
  #has_many :sites, :through => :site_listings, :dependent => :destroy

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  default_scope :order => "updated_at DESC"

  # set active status
  def activate
    if self.status != 'sold'
      self.id, self.status, self.start_date = nil, 'active', Time.now 
      set_end_date
    end
    self
  end

  # check for free pixi posting
  def self.free_order? val
    active.get_by_site(val).count < SITE_FREE_AMT ? true : false rescue nil
  end

  # paginate
  def self.active_page ip="127.0.0.1", pg=1, range=25
    active.where(site_id: Contact.near(ip, range).get_by_type('Site').map(&:contactable_id).uniq).paginate(page: pg)
  end

  # get pixis by category id
  def self.get_by_category cid, pg=1
    active.where(:category_id => cid).paginate page: pg
  end

  # get pixis by category & site ids
  def self.get_category_by_site cid, sid, pg=1
    unless sid.blank?
      active.where('category_id = ? and site_id = ?', cid, sid).paginate page: pg
    else
      get_by_category cid, pg
    end
  end

  # get active pixis by city
  def self.active_by_city city, state, pg
    stmt = "city = ? and state = ?"
    active.where(site_id: Contact.where(stmt, city, state).get_by_type('Site').map(&:contactable_id).uniq).paginate(page: pg)
  end

  # get pixis by city
  def self.get_by_city cid, sid, pg=1
    # check if site is a city
    unless loc = Site.where("id = ? and org_type = ?", sid, 'city').first
      cid.blank? ? get_by_site(sid, pg) : get_category_by_site(cid, sid, pg)
    else
      # get active pixis by site's city and state
      unless loc.contacts.blank?
        city, state = loc.contacts[0].city, loc.contacts[0].state
        cid.blank? ? active_by_city(city, state, pg) : where('category_id = ?', cid).active_by_city(city, state, pg) 
      else
        # get pixis by ids
        cid.blank? ? get_by_site(sid, pg) : get_category_by_site(cid, sid, pg)
      end
    end
  end

  # get active pixis by site id
  def self.get_by_site sid, pg=1
    active.where(:site_id => sid).paginate page: pg
  end

  # get invoice
  def get_invoice val
    invoices.where(:id => val).first rescue nil
  end

  # verify if listing is sold
  def sold?
    status == 'sold'
  end

  # mark pixi as sold
  def mark_as_sold
    unless sold?
      self.status = 'sold'
      save!
    else
      errors.add(:base, 'Pixi already marked as sold.')
      false
    end
  end

  # sphinx scopes
  sphinx_scope(:latest_first) {
    {:order => 'updated_at DESC, created_at DESC'}
  }

  sphinx_scope(:by_title) { |title|
    {:conditions => {:title => title}}
  }

  sphinx_scope(:by_point) do |lat, lng|
    {:geo => [lat, lng]}
  end
end
