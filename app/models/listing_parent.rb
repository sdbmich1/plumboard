require 'rails_rinku'
class ListingParent < ActiveRecord::Base
  resourcify
  self.abstract_class = true
  self.per_page = 20

  before_update :must_have_pictures

  # load pixi config keys
  ALIAS_LENGTH = PIXI_KEYS['pixi']['alias_length']
  KEY_LENGTH = PIXI_KEYS['pixi']['key_length']
  SITE_FREE_AMT = PIXI_KEYS['pixi']['site_init_free']
  MAX_PIXI_PIX = PIXI_KEYS['pixi']['max_pixi_pix']

  attr_accessible :buyer_id, :category_id, :description, :title, :seller_id, :status, :price, :show_alias_flg, :show_phone_flg, :alias_name,
  	:site_id, :start_date, :end_date, :transaction_id, :pictures_attributes, :pixi_id, :parent_pixi_id, :year_built, :pixan_id, :job_type,
	:edited_by, :edited_dt, :post_ip, :lng, :lat, :event_start_date, :event_end_date, :compensation, :event_start_time, :event_end_time,
	:explanation, :contacts_attributes

  belongs_to :user, foreign_key: :seller_id
  belongs_to :site
  belongs_to :category
  belongs_to :transaction

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  has_many :contacts, :as => :contactable, :dependent => :destroy
  accepts_nested_attributes_for :contacts, :allow_destroy => true

  validates :title, :presence => true, :length => { :maximum => 80 }
  validates :description, :presence => true
  validates :seller_id, :presence => true
  validates :site_id, :presence => true
  validates :start_date, :presence => true
  validates :category_id, :presence => true
  validates :price, allow_blank: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
    		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }
  validate :must_have_pictures

  # event date and time
  validates_date :event_start_date, on_or_after: lambda { Date.current }, presence: true, if: :event?
  validates_date :event_end_date, on_or_after: :event_start_date, presence: true, if: :start_date?
  validates_datetime :event_start_time, presence: true, if: :start_date?
  validates_datetime :event_end_time, presence: true, after: :event_start_time, :if => :start_date?

  # geocode
  geocoded_by :post_ip, :latitude => :lat, :longitude => :lng
  after_validation :geocode

  # check if pixi is an event
  def event?
    category.category_type == 'event' rescue nil
  end

  # check if pixi can have a year
  def has_year?
    category.category_type == 'asset' rescue nil
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

  # define where clause based on rails env
  def self.where_stmt
    if Rails.env.development? || Rails.env.test?
      "listings.status = 'active'"
    else
      "listings.status = 'active' AND listings.end_date >= curdate()"
    end
  end

  # select active listings
  def self.active
    select('listings.id, listings.pixi_id, listings.title, listings.category_id, categories.name AS category_name, listings.updated_at,
      listings.status, listings.description, listings.created_at, listings.seller_id, listings.site_id, listings.price')
    .joins(:category)
    .includes(:pictures)
    .where(where_stmt)
    .reorder('listings.updated_at DESC')
  end

  # find listings by status
  def self.get_by_status val
    includes(:pictures, :user).where(:status => val).order('updated_at DESC')
  end

  # find listings by seller user id
  def self.get_by_seller val
    where(:seller_id => val)
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
    status == 'sold'
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

  # verify if pixi posted by PXB
  def pixi_post?
    !pixan_id.blank?
  end

  # get category name for a listing
  def category_name
    category.name.titleize rescue nil
  end

  # get site name for a listing
  def site_name
    site.name rescue nil
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

  # short description
  def brief_descr
    descr = description.length < 96 ? description.html_safe : description.html_safe[0..96] + '...' rescue nil
    Rinku.auto_link(descr) if descr
  end

  # add hyperlinks to description
  def summary
    Rinku.auto_link(description.html_safe) rescue nil
  end

  # titleize title
  def nice_title
    unless title.blank?
      str = price.blank? ? '' : ' - $' + price.to_i.to_s
      title.index('$') ? title.titleize : title.titleize + str 
    else
      nil
    end
  end

  # short title
  def short_title
    nice_title.length < 14 ? nice_title.html_safe : nice_title.html_safe[0..14] + '...' rescue nil
  end

  # med title
  def med_title
    nice_title.length < 25 ? nice_title.html_safe : nice_title.html_safe[0..25] + '...' rescue nil
  end

  # set end date to x days after start to denote when listing is no longer displayed on network
  def set_end_date
    self.end_date = self.start_date + PIXI_DAYS.days
  end

  # get number of sites where pixi is posted
  def get_site_count
    site_name ? 1 : site_listings.size
  end

  # set nice time
  def get_local_time(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y %I:%M%p') rescue nil
  end

  # check for premium categories
  def premium?
    category.premium? rescue nil
  end

  # check if pixi is a job
  def job?
    category.category_type == 'employment' rescue nil
  end

  # duplicate pixi between models
  def dup_pixi tmpFlg
    
    # check for temp or active pixi based on flag
    listing = tmpFlg ? Listing.find_pixi(self.pixi_id) : TempListing.find_pixi(self.pixi_id)

    unless listing
      attr = self.attributes  # copy attributes

      # remove protected attributes
      %w(id created_at updated_at).map {|x| attr.delete x}

      # load attributes to new record
      listing = tmpFlg ? Listing.new(attr) : TempListing.new(attr)
      listing.status = 'edit' unless tmpFlg
    end

    # add photos
    self.pictures.each do |pic|

      # check if listing & photo already exists for pixi edit
      if tmpFlg && !listing.new_record? 
        next if listing.pictures.where(:photo_file_name => pic.photo_file_name).first
      end

      # add photo
      listing.pictures.build(:photo => pic.photo)
    end

    # update fields
    if tmpFlg && listing 
      listing.title, listing.price, listing.category_id, listing.site_id = self.title, self.price, self.category_id, self.site_id
      listing.description, listing.compensation, listing.status = self.description, self.compensation, 'active'
      listing.event_start_date, listing.event_start_time = self.event_start_date, self.event_start_time
      listing.event_end_date, listing.event_end_time = self.event_end_date, self.event_end_time
      listing.pixan_id, listing.year_built, listing.buyer_id = self.pixan_id, self.year_built, self.buyer_id
      listing.show_phone_flg, listing.start_date, listing.end_date = self.show_phone_flg, self.start_date, self.end_date
      listing.post_ip, listing.lat, listing.lng, listing.edited_by = self.post_ip, self.lat, self.lng, self.edited_by
    end

    # add dup
    listing.save ? listing : false rescue false
  end

  # seller pic
  def seller_photo
    user.photo rescue nil
  end

  # seller pic
  def seller_rating_count
    user.seller_ratings.size rescue 0
  end

  # display first image
  def photo_url
    pictures[0].photo.url rescue nil
  end

  # format start date
  def start_dt
    start_date.strftime('%m/%d/%Y') rescue nil
  end

  # format updated date
  def updated_dt
    updated_at.utc.getlocal.strftime('%m/%d/%Y %l:%M %p') rescue nil
  end

  # set json string
  def as_json(options={})
    super(methods: [:seller_name, :seller_photo, :summary, :short_title, :nice_title,
        :category_name, :site_name, :start_dt, :seller_first_name, :med_title], 
      include: {pictures: { only: [:photo_file_name], methods: [:photo_url] }})
  end
end
