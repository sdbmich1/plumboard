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
  	:site_id, :start_date, :end_date, :transaction_id, :pictures_attributes, :pixi_id, :parent_pixi_id, :year_built,
	:edited_by, :edited_dt, :post_ip, :lng, :lat, :event_start_date, :event_end_date, :compensation, :event_start_time, :event_end_time

  belongs_to :user, :foreign_key => :seller_id
  belongs_to :site
  belongs_to :category
  belongs_to :transaction

  validates :title, :presence => true, :length => { :maximum => 80 }
  validates :description, :presence => true
  validates :seller_id, :presence => true
  validates :site_id, :presence => true
  validates :start_date, :presence => true
  validates :category_id, :presence => true
  validates :price, :allow_blank => true, :numericality => { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }
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
    %w(Event Events Happenings).detect { |cat| cat == category_name }
  end

  # check if pixi can have a year
  def has_year?
    %w(Automotive Antiques Motorcycle Boats).detect { |cat| cat == category_name }
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

  # select active listings
  def self.active
    if Rails.env.development? || Rails.env.test?
      where(:status=>'active').order('updated_at DESC')
    else
      where("status = 'active' AND end_date >= curdate()").order('updated_at DESC')
    end
  end

  # find listings by status
  def self.get_by_status val
    where(:status => val).order('updated_at DESC')
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

  # verify if listing is edit
  def edit?
    status == 'edit'
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
    title.titleize rescue nil
  end

  # short title
  def short_title
    nice_title.length < 14 ? nice_title.html_safe : nice_title.html_safe[0..14] + '...' rescue nil
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
    %w(Gigs Jobs Employment).detect { |cat| cat == category_name}
  end
end
