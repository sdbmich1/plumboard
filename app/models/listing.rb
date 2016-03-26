class Listing < ListingParent
  self.table_name = "listings"
  include ThinkingSphinx::Scopes

  before_create :activate
  after_commit :async_send_notification, :update_counter_cache, :on => :create
  after_commit :send_saved_pixi_removed, :sync_saved_pixis, :set_invoice_status, :update_counter_cache, :on => :update

  attr_accessor :parent_pixi_id

  belongs_to :user, foreign_key: :seller_id, counter_cache: 'active_listings_count'
  belongs_to :buyer, foreign_key: 'buyer_id', class_name: 'User'
  has_many :conversations, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :posts, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :comments, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :pixi_likes, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :pixi_wants, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :saved_listings, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :active_saved_listings, -> { where status: 'active' }, primary_key: 'pixi_id', foreign_key: 'pixi_id', class_name: 'SavedListing'
  has_many :pixi_asks, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  #has_many :site_listings, :dependent => :destroy
  #has_many :sites, :through => :site_listings, :dependent => :destroy
  has_many :invoice_details, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :invoices, through: :invoice_details, :dependent => :destroy
  has_many :active_pixi_wants, -> { where status: 'active' }, primary_key: 'pixi_id', foreign_key: 'pixi_id', class_name: 'PixiWant'

  # finds specific pixi
  def self.find_pixi pid
    includes(:pictures, :pixi_likes, :active_pixi_wants, :active_saved_listings, :category, :user => [:pictures], 
      :comments=> {:user=>[:pictures]}).where(pixi_id: pid).first
  end

  def self.inc_types
    includes(:condition_type, :event_type, :fulfillment_type, :job_type)
  end

  # set active status
  def activate
    ListingProcessor.new(self).activate
  end

  # check for free pixi posting
  def self.free_order? val
    active.get_by_site(val).count < SITE_FREE_AMT ? true : false rescue nil
  end

  # paginate
  def self.active_page ip="127.0.0.1", pg=1, range=25
    ListingQueryProcessor.new(self).active_page ip, pg, range
  end

  # get pixis by category id
  def self.get_by_category cid, get_active=true
    ListingQueryProcessor.new(self).get_by_category cid, get_active
  end

  # get all active pixis that have at least one unpaid invoice and no sold invoices
  def self.active_invoices
    active.joins(:invoices).where("invoices.status = 'unpaid'")
  end

  # get cool list by user
  def self.cool_list usr, pg=1
    active.joins(:pixi_likes).where("pixi_likes.user_id = ?", usr.id).paginate page: pg
  end

 # get asked list by user
  def self.asked_list usr, pg=1
    active.joins(:pixi_asks).where("pixi_asks.user_id = ?", usr.id).paginate page: pg
  end

  # find listings by buyer user id
  def self.get_by_buyer val
    includes(:invoices).references(:invoices).where('invoices.buyer_id = ?', val)
  end

  # get all active pixis with an end_date less than today and update their statuses to expired
  def self.close_pixis
    where("status = ? AND end_date < ?", 'active', Date.today).update_all(status: 'expired')
  end

  # get invoiced listings by status and, if provided, category and location
  def self.check_invoiced_category_and_location cid, loc
    result = select_fields("listings.updated_at").active_invoices
    cid || loc ? result.get_by_city(cid, loc, true) : result
  end

  # get invoice
  def get_invoice val
    invoices.where(:id => val).first rescue nil
  end

  # mark pixi as sold
  def mark_as_sold
    ListingProcessor.new(self).mark_as_sold
  end

  # return wanted count 
  def wanted_count
    active_pixi_wants.size rescue 0
  end

  # return asked count 
  def asked_count
    pixi_asks.size rescue 0
  end

  # return whether pixi is wanted
  def is_wanted?
    wanted_count > 0 rescue nil
  end

 # return whether pixi is asked
  def is_asked?
    asked_count > 0 rescue nil
  end

  # return whether pixi is wanted by user
  def user_wanted? usr
    active_pixi_wants.where(user_id: usr.id).first rescue nil
  end

  # return whether pixi is asked by user
  def user_asked? usr
    pixi_asks.where(user_id: usr.id).first rescue nil
  end

  # return liked count 
  def liked_count
    pixi_likes.size rescue 0
  end

  # return msg count 
  def msg_count
    conversations.first.posts.size rescue 0
  end

  # return whether pixi is liked
  def is_liked?
    liked_count > 0 rescue nil
  end

  # return whether pixi is liked by user
  def user_liked? usr
    pixi_likes.where(user_id: usr.id).first
  end

  # return saved count 
  def saved_count
    active_saved_listings.size rescue 0
  end

  # return whether pixi is saved
  def is_saved?
    saved_count > 0 rescue nil
  end

  # return whether pixi is saved by user
  def user_saved? usr
    active_saved_listings.where(user_id: usr.id).first
  end

  # return whether region has enough pixis
  def self.has_enough_pixis? cat, loc
    get_by_city(cat, loc).size >= MIN_PIXI_COUNT rescue false
  end

  # return wanted users 
  def self.wanted_users pid
    select("users.id, CONCAT(users.first_name, ' ', users.last_name) AS name, users.updated_at, users.created_at")
      .joins(:pixi_wants => [:user]).where(pixi_id: pid).order("users.first_name")
  end

  # return asked users 
  def self.asked_users pid
    select("users.id, CONCAT(users.first_name, ' ', users.last_name) AS name, users.updated_at, users.created_at")
      .joins(:pixi_asks => [:user]).where(pixi_id: pid).order("users.first_name")
  end

  # mark saved pixis if sold or closed
  def sync_saved_pixis
    ListingProcessor.new(self).sync_saved_pixis
  end

  # sends email to users who saved the listing when listing is removed
  def send_saved_pixi_removed
    ListingProcessor.new(self).send_saved_pixi_removed
  end

  # sends notifications after pixi is posted to board
  def async_send_notification 
    ListingProcessor.new(self).async_send_notification 
  end

  # toggle invoice status on removing pixi from board
  def set_invoice_status
    ListingProcessor.new(self).set_invoice_status
  end

  # set remove item list based on pixi type
  def remove_item_list
    ListingProcessor.new(self).remove_item_list
  end

  # process pixi repost based on pixi status
  def repost
    ListingProcessor.new(self).repost
  end

  # return all pixis with wants that are more than number_of_days old and either have no invoices, no price, or are jobs
  def self.invoiceless_pixis number_of_days=2
    ListingProcessor.new(self).invoiceless_pixis number_of_days
  end

  # returns purchased pixis from buyer
  def self.purchased usr
    include_list.select_fields('invoices.updated_at').joins(:invoices).where("invoices.buyer_id = ? AND invoices.status = ?", usr.id, 'paid').uniq
  end

  # returns sold pixis from seller
  def self.sold_list usr=nil
    ListingProcessor.new(self).sold_list usr
  end

  # get saved list by user
  def self.saved_list usr, pg=1
    result = select_fields('saved_listings.updated_at').active.joins(:saved_listings)
    result.where("saved_listings.status = 'active' AND saved_listings.user_id = ?", usr.id).paginate page: pg
  end

  # get wanted list by user
  def self.wanted_list usr, cid=nil, loc=nil, adminFlg=true
    ListingDataProcessor.new(Listing.new).wanted_list(usr, cid, loc, adminFlg)
  end

  # toggle get_by_seller call based on status
  def self.get_by_status_and_seller val, usr, adminFlg
    val == 'sold' ? sold_list(usr) : select_fields(created_date(val)).get_by_seller(usr, val, adminFlg).get_by_status(val)
  end

  def self.created_date val
    val == "active" ? "end_date" : "updated_at"
  end

  # refresh counter cache
  def update_counter_cache
    ListingProcessor.new(self).update_counter_cache
  end

  def self.get_by_url url, action, cid=''
    ListingProcessor.new(self).get_by_url url, action, cid
  end

  def self.board_fields
    select("#{ListingProcessor.new(self).get_board_flds}")
  end

  def self.load_board cid, sid
    inc_types.get_by_city(cid, sid).board_fields
  end

  # set promo code for free order if appropriate
  def set_promo_code
    PIXI_KEYS['pixi']['launch_promo_cd'] if self.class.free_order?(site_id)
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
