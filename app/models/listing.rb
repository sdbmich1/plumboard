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
  def self.active_page pg
    active.paginate page: pg
  end

  # get pixis by category id
  def self.get_by_category cid, pg
    active.where(:category_id => cid).paginate page: pg
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
end
