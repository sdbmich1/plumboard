require 'rinku'
require 'digest/md5'
class ListingParent < ActiveRecord::Base
  resourcify
  include Area, ResetDate, LocationManager, NameParse, ProcessMethod
  self.abstract_class = true
  self.per_page = 20

  before_update :must_have_pictures

  # load pixi config keys
  ALIAS_LENGTH = PIXI_KEYS['pixi']['alias_length']
  KEY_LENGTH = PIXI_KEYS['pixi']['key_length']
  SITE_FREE_AMT = PIXI_KEYS['pixi']['site_init_free']
  MAX_PIXI_PIX = PIXI_KEYS['pixi']['max_pixi_pix']

  attr_accessible :buyer_id, :category_id, :description, :title, :seller_id, :status, :price, :show_alias_flg, :show_phone_flg, :alias_name,
  	:site_id, :start_date, :end_date, :transaction_id, :pictures_attributes, :pixi_id, :parent_pixi_id, :year_built, :pixan_id, 
	:job_type_code, :event_type_code, :edited_by, :edited_dt, :post_ip, :lng, :lat, :event_start_date, :event_end_date, :compensation,
	:event_start_time, :event_end_time, :explanation, :contacts_attributes, :repost_flg, :mileage, :other_id, :condition_type_code,
	:color, :quantity, :item_type, :item_size, :bed_no, :bath_no, :term, :avail_date

  attr_accessor :skip_approval_email

  belongs_to :user, foreign_key: :seller_id
  belongs_to :site
  belongs_to :category
  belongs_to :transaction
  belongs_to :job_type, primary_key: 'code', foreign_key: 'job_type_code'
  belongs_to :event_type, primary_key: 'code', foreign_key: 'event_type_code'
  belongs_to :condition_type, primary_key: 'code', foreign_key: 'condition_type_code'

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  has_many :contacts, :as => :contactable, :dependent => :destroy
  accepts_nested_attributes_for :contacts, :allow_destroy => true, :reject_if => :all_blank

  validates :title, :presence => true, :length => { :maximum => 80 }
  validates_presence_of :seller_id, :site_id, :start_date, :category_id, :description
  validates :job_type_code, :presence => true, if: :job?
  validates :event_type_code, :presence => true, if: :event?
  validates :price, allow_blank: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
    		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }
  validate :must_have_pictures

  # event date and time
  validates_date :event_start_date, on_or_after: lambda { Date.today }, presence: true, if: :event?
  validates_date :event_end_date, on_or_after: :event_start_date, presence: true, if: :start_date?
  validates_datetime :event_start_time, presence: true, if: :start_date?
  validates_datetime :event_end_time, presence: true, after: :event_start_time, :if => :start_date?

  # geocode
  geocoded_by :primary_address, :latitude => :lat, :longitude => :lng
  after_validation :geocode

  # used to handle pagination settings
  def self.set_page pg=1
    paginate page: pg, per_page: MIN_BOARD_AMT
  end

  # check if pixi is a job
  def job?
    is_category_type? 'employment'
  end

  # check if pixi is an event
  def event?
    is_category_type? 'event'
  end

  # check if pixi is a given category type
  def is_category_type? val
    val.include? category.category_type_code rescue false
  end

  # check if pixi has a given status
  def has_status? val
    val.include? status rescue false
  end

  # check if pixi can have a year
  def has_year?
    is_category_type? %w(asset vehicle)
  end

  # check if event start date exists
  def start_date?
    !event_start_date.blank?
  end

  # check if event starts and ends on same date
  def same_day?
    start_date? && event_start_date == event_end_date
  end

  # reset default controller id parameter to pixi_id
  def to_param
    pixi_id
  end

  # validate existance of at least one picture
  def must_have_pictures
    if !any_pix? || pictures.all? {|pic| pic.marked_for_destruction? }
      errors.add(:base, 'Must have at least one picture')
    elsif pictures.size > MAX_PIXI_PIX.to_i
      errors.add(:base, "Can only have #{MAX_PIXI_PIX} pictures")
    else
      return true
    end
    false
  end

  # check if pictures already exists
  def any_pix?
    pictures.detect { |x| x && !x.photo_file_name.nil? }
  end

  # check if pictures already exists
  def any_locations?
    contacts.detect { |x| x && !x.address.nil? }
  end

  # define where clause based on rails env
  def self.where_stmt
    "listings.status = 'active'" + (Rails.env.development? || Rails.env.test? ? '' : " AND listings.end_date >= curdate()")
  end

  # select active listings
  def self.active
    include_list.where(where_stmt).reorder('listings.updated_at DESC')
  end

  # see include_list_without_job_type
  def self.active_without_job_type
    include_list_without_job_type.where(where_stmt).reorder('listings.updated_at DESC')
  end    

  # eager load assns
  def self.include_list
    includes(:pictures, :site, :category, :job_type, :contacts, :user)
  end

  # leaves out job_type to avoid unused eager loading
  def self.include_list_without_job_type
    includes(:pictures, :site, :category, :contacts, :user)
  end

  # find listings by status
  def self.get_by_status val
    val == 'sold' ? sold_list : include_list_without_job_type.where(:status => val)
  end
 
  # get active pixis by site id
  def self.get_by_site sid, get_active=true
    ListingDataProcessor.new(self).get_by_site sid, get_active
  end
  
  # get active pixis by category
  def self.get_by_category cid, get_active=true
    ListingDataProcessor.new(self).get_by_category cid, get_active
  end

  # find all listings where a given user is the seller, or all listings if the user is an admin
  def self.get_by_seller user, adminFlg=true
    model = self.respond_to?(:sold_list) ? 'listings' : 'temp_listings'
    query = user.is_admin? && adminFlg ? "#{model}.seller_id IS NOT NULL" : "#{model}.seller_id = #{user.id}"
    include_list.where(query).reorder("#{model}.updated_at DESC")
  end

  # get listings by status and, if provided, category and location
  def self.check_category_and_location status, cid, loc, activeFlg
    cid || loc ? get_by_status(status).get_by_city(cid, loc, activeFlg) : get_by_status(status)
  end

  # verify if listing has been paid for
  def has_transaction?
    !transaction_id.blank?
  end

  # verify if listing is active
  def active?
    status == 'active'
  end

  # verify if listing is pending
  def pending?
    status == 'pending'
  end

  # check if listing is denied
  def denied?
    status == 'denied'
  end

  # verify if listing is edit
  def edit?
    status == 'edit'
  end

  # verify if listing is sold
  def sold?
    self.is_a?(Listing) && invoices.exists?(status: 'paid')
  end

  # verify if listing is inactive
  def inactive?
    status == 'inactive'
  end

  # verify if listing is closed
  def closed?
    status == 'closed'
  end

  # verify if listing is removed
  def removed?
    status == 'removed'
  end

  # verify if listing is removed
  def expired?
    status == 'expired'
  end

  # verify if alias is used
  def alias?
    show_alias_flg == 'yes'
  end

  # check if listing is new
  def new_status?
    status == 'new'
  end

  # verify if current user is listing seller
  def seller? usr
    seller_id == usr.id rescue nil
  end

  # verify if current user is pixter
  def pixter? usr
    pixan_id == usr.id rescue nil
  end

  # verify if pixi posted by PXB
  def pixi_post?
    !pixan_id.blank?
  end

  # verify pixi can be edited
  def editable? usr
    (seller?(usr) || pixter?(usr) || usr.has_role?(:admin)) || usr.has_role?(:support)
  end

  # get category name for a listing
  def category_name
    category.name.titleize rescue nil
  end

  # get site name for a listing
  def site_name
    site.name rescue nil
  end

  # get condition
  def condition
    condition_type.description rescue nil
  end

  # get seller name for a listing
  def seller_name
    alias? ? alias_name : user.name rescue nil
  end

  # get seller first name for a listing
  def seller_first_name
    user.first_name rescue nil
  end

  # get seller email for a listing
  def seller_email
    user.email rescue nil
  end

  # check if sold by business
  def sold_by_business? 
    user.is_business? rescue false
  end

  # check if seller has address
  def seller_address? 
    sold_by_business? && user.has_address? rescue false
  end

  def has_address?
    any_locations? || seller_address?
  end

  # short description
  def brief_descr val=96
    ListingDataProcessor.new(self).set_str description, val
  end

  # add hyperlinks to description
  def summary
    ListingDataProcessor.new(self).set_auto_link description
  end

  # titleize title
  def nice_title prcFlg=true
    ListingDataProcessor.new(self).nice_title prcFlg
  end

  # short title
  def short_title prcFlg=true, val=14
    ListingDataProcessor.new(self).set_str nice_title(prcFlg), val
  end

  # med title
  def med_title prcFlg=true, val=25
    short_title prcFlg, val
  end

  # set end date to x days after start to denote when listing is no longer displayed on network
  def set_end_date
    self.end_date = self.start_date + PIXI_DAYS.days rescue nil
  end

  # get number of sites where pixi is posted
  def get_site_count
    site_name ? 1 : 0
  end

  # set nice time
  def get_local_time(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y %I:%M%p') rescue nil
  end

  # check for premium categories
  def premium?
    category.premium? rescue nil
  end

  # delete selected photo
  def delete_photo pid, val=1
    ListingDataProcessor.new(self).delete_photo pid, val
  end

  # duplicate pixi between models
  def dup_pixi tmpFlg, repost=false
    ListingDataProcessor.new(self).dup_pixi tmpFlg, repost
  end

  # seller pic
  def seller_photo
    user.photo rescue nil
  end

  # seller pic
  def seller_rating_count
    user.rating_count rescue 0
  end

  # display first image
  def photo_url
    pictures[0].photo.url rescue nil
  end

  # format start date
  def start_dt
    start_date.strftime('%m/%d/%Y') rescue nil
  end

  # format date
  def format_date dt
    ListingDataProcessor.new(self).format_date dt
  end

  # format date based on location
  def display_date dt, dFlg=true
    ListingDataProcessor.new(self).display_date dt, dFlg
  end

  # get site address
  def primary_address
    ListingDataProcessor.new(self).primary_address
  end

  # get job type name
  def job_type_name
    job_type.job_name rescue nil
  end

  # set json string
  def as_json(options={})
    super(methods: [:seller_name, :seller_photo, :summary, :short_title, :nice_title,
        :category_name, :site_name, :start_dt, :seller_first_name, :med_title, :amt_left], 
      include: {pictures: { only: [:photo_file_name], methods: [:photo_url] }})
  end

  # get pixter name
  def pixter_name
    ListingDataProcessor.new(self).pixter_name
  end

  # specifies which child is used
  def self.get_class
    self.respond_to?(:sold_list) ? Listing.new : TempListing.new
  end

  # check site's org_type and call the corresponding active_by method, or get pixis by ids if this fails
  def self.get_by_city cid, sid, get_active=true
    ListingDataProcessor.new(get_class).get_by_city cid, sid, get_active
  end

  # set unique key
  def generate_token
    ListingDataProcessor.new(self).generate_token
  end

  def add_photos tmpFlg, listing
    ListingDataProcessor.new(self).add_photos tmpFlg, listing
  end

  # titleize description
  def event_type_descr
    event_type.description.titleize rescue nil
  end

  def as_csv(options={})
    row = { "Title" => title, "Category" => category_name, "Description" => description, "Location" => site_name }
    row["Buyer Name"] = invoices.where(status: "paid").first.buyer_name if options[:style] == "sold"
    date_entry = %w(sold wanted purchased saved).include?(options[:style]) ? created_date : updated_at
    row[options[:style].titleize + " Date"] = display_date(date_entry)
    row
  end

  # get expiring pixis
  def self.soon_expiring_pixis number_of_days=7, status='active' 
    get_by_status(status).where("cast(end_date As Date) = ?", Date.today + number_of_days.days)
  end

  # count number of sales
  def sold_count
    invoices.where(status: 'paid').sum("invoice_details.quantity") rescue 0
  end

  # determine amount left
  def amt_left
    ListingDataProcessor.new(self).amt_left
  end

  # set csv filename
  def self.filename status
    ListingDataProcessor.new(self).filename status
  end
end
