class Listing < ListingParent
  self.table_name = "listings"
  include ThinkingSphinx::Scopes

  before_create :activate
  after_commit :async_send_notification, :on => :create
  after_commit :send_saved_pixi_removed, :sync_saved_pixis, :set_invoice_status, :on => :update

  attr_accessor :parent_pixi_id

  belongs_to :buyer, foreign_key: 'buyer_id', class_name: 'User'
  has_many :conversations, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :posts, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :comments, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :pixi_likes, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :pixi_wants, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :saved_listings, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :invoice_details, primary_key: 'pixi_id', foreign_key: 'pixi_id', :dependent => :destroy
  has_many :invoices, through: :invoice_details, :dependent => :destroy
  has_many :active_pixi_wants, primary_key: 'pixi_id', foreign_key: 'pixi_id', class_name: 'PixiWant', conditions: { :status => 'active' }

  default_scope :order => "updated_at DESC"

  # finds specific pixi
  def self.find_pixi pid
    includes(:pictures, :pixi_likes, :pixi_wants, :saved_listings, :category, :user => [:pictures], 
      :comments=> {:user=>:pictures}).where(pixi_id: pid).first
  end

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
    if Rails.env.development?
      active.set_page pg
    else
      active.where(site_id: Contact.proximity(ip, range)).set_page pg
    end
  end

  # get pixis by category id
  def self.get_by_category cid, pg=1
    active.where(:category_id => cid).set_page pg
  end

  # get all active pixis that have at least one unpaid invoice and no sold invoices
  def self.active_invoices
    active.joins(:invoices).where("invoices.status = 'active'")
  end

  # get saved list by user
  def self.saved_list usr, pg=1
    active.joins(:saved_listings).where("saved_listings.status = 'active' AND saved_listings.user_id = ?", usr.id).paginate page: pg
  end

  # get wanted list by user
  def self.wanted_list usr, pg=1, cid=nil, loc=nil
    if usr.is_admin?
      active.joins(:pixi_wants).where("pixi_wants.user_id is not null AND pixi_wants.status = ?", 'active')
      .get_by_city(cid, loc, pg, false).paginate(page: pg)
    else
      active.joins(:pixi_wants).where("pixi_wants.user_id = ? AND pixi_wants.status = ?", usr.id, 'active').paginate page: pg
    end
  end

  # get cool list by user
  def self.cool_list usr, pg=1
    active.joins(:pixi_likes).where("pixi_likes.user_id = ?", usr.id).paginate page: pg
  end

  # find listings by buyer user id
  def self.get_by_buyer val
    where(:buyer_id => val)
  end

  # get all active pixis with an end_date less than today and update their statuses to closed
  def self.close_pixis
    active.where("end_date < ?", Date.today).update_all(status: 'closed')
  end

  # get invoiced listings by status and, if provided, category and location
  def self.check_invoiced_category_and_location cid, loc, pg=1
    if cid.blank? && loc.blank?
      active_invoices
    else
      active_invoices.get_by_city(cid, loc, pg, false)
    end
  end

  # get invoice
  def get_invoice val
    invoices.where(:id => val).first rescue nil
  end

  # mark pixi as sold
  def mark_as_sold
    unless sold?
      self.update_attribute(:status, 'sold') if amt_left == 0
    else
      errors.add(:base, 'Pixi already marked as sold.')
      false
    end
  end

  # return wanted count 
  def wanted_count
    active_pixi_wants.size rescue 0
  end

  # return whether pixi is wanted
  def is_wanted?
    wanted_count > 0 rescue nil
  end

  # return whether pixi is wanted by user
  def user_wanted? usr
    active_pixi_wants.where(user_id: usr.id).first rescue nil
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
    saved_listings.size rescue 0
  end

  # return whether pixi is saved
  def is_saved?
    saved_count > 0 rescue nil
  end

  # return whether pixi is saved by user
  def user_saved? usr
    saved_listings.where(user_id: usr.id).first
  end

  # return whether region has enough pixis
  def self.has_enough_pixis? cat, loc, pg=1
    get_by_city(cat, loc, pg).size >= MIN_PIXI_COUNT rescue false
  end

  # return wanted users 
  def self.wanted_users pid
    select("users.id, CONCAT(users.first_name, ' ', users.last_name) AS name, users.updated_at, users.created_at")
      .joins(:pixi_wants => [:user]).where(pixi_id: pid).order("users.first_name")
  end

  # mark saved pixis if sold or closed
  def sync_saved_pixis
    SavedListing.update_status pixi_id, status unless active?
  end

  # sends email to users who saved the listing when listing is removed
  def send_saved_pixi_removed
    closed = ['closed', 'sold', 'removed', 'inactive', 'expired']
    if closed.detect {|closed| self.status == closed }
      saved_listings = SavedListing.where(pixi_id: pixi_id) rescue nil
      saved_listings.each do |saved_listing|
        if closed.detect {|closed| saved_listing.status == closed }
          UserMailer.delay.send_saved_pixi_removed(saved_listing) unless self.buyer_id == saved_listing.user_id
        end
      end
    end
  end

  # sends notifications after pixi is posted to board
  def async_send_notification 
    if active?
      ptype = self.premium? ? 'app' : 'abp' 
      val = self.repost_flg ? 'repost' : 'approve'

      # update points
      PointManager::add_points self.user, ptype if self.user

      # send system message to user
      SystemMessenger::send_message self.user, self, val rescue nil

      # remove temp pixi
      delete_temp_pixi self.pixi_id unless repost_flg

      # send approval message
      UserMailer.delay.send_approval(self)
    end
  end

  # remove temp pixi
  def delete_temp_pixi pid
    TempListing.destroy_all(pixi_id: pid)
  end

  # toggle invoice status on removing pixi from board
  def set_invoice_status
    if %w(expired removed inactive closed).detect { |x| x == self.status }
      invoices.find_each do |inv|
        if inv.invoice_details.size == 1 
	  inv.update_attribute(:status, 'removed')
	end
      end
    end
  end

  # set remove item list based on pixi type
  def remove_item_list
    if job? 
      ['Filled Position', 'Removed Job']
    elsif event?  
      ['Event Cancelled', 'Event Ended']
    else
      ['Changed Mind', 'Donated Item', 'Gave Away Item', 'Sold Item']
    end
  end

  # reposts existing sold, removed or expired pixi as new
  def repost_pixi
    listing = Listing.new(get_attr(true))

    # add photos
    listing = add_photos false, listing

    # add token
    listing.generate_token
    listing.status, listing.repost_flg = 'active', true
    listing.save
  end

  # process pixi repost based on pixi status
  def repost
    if expired? || removed?
      self.status, self.repost_flg, self.explanation  = 'active', true, nil
      self.save
      async_send_notification # send notification
    elsif sold?
      repost_pixi
    else
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
