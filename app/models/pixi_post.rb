class PixiPost < ActiveRecord::Base
  resourcify
  include AddressManager

  before_save :set_flds

  attr_accessor :pixan_name
  attr_accessible :address, :alt_date, :alt_time, :city, :description, :pixan_id, :preferred_date, :preferred_time, :quantity, :state, 
    :user_id, :value, :zip, :status, :appt_time, :appt_date, :completed_date, :completed_time, :home_phone, :mobile_phone, :address2, 
    :comments, :editor_id, :pixan_name, :pixi_id, :country

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :pixan, foreign_key: "pixan_id", class_name: "User"

  validates :user_id, presence: true
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 50, less_than_or_equal_to: MAX_PIXI_AMT.to_f }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :address, presence: true, length: {maximum: 50}
  validates :city, presence: true, length: {maximum: 30}
  validates :state, presence: true
  validates :zip, presence: true, length: {is: 5}
  validates :description, presence: true
  validates :preferred_time, presence: true
  validates :pixan_id, presence: true, if: :has_appt? || :is_completed?
  validates :pixi_id, presence: true, unless: "completed_date.nil?"
  validates :home_phone, presence: true, length: {in: 10..15}
  validates :mobile_phone, allow_blank: true, length: {in: 10..15}
  validate :zip_service_area
  validates_date :preferred_date, presence: true, on_or_after: :min_start_date, unless: :is_admin?
  validates_date :alt_date, allow_blank: true, on_or_after: :min_start_date, unless: :is_admin?
  validates_date :appt_date, on_or_after: :today, presence: true, if: :can_set_appt?
  validates_date :completed_date, on_or_after: :today, presence: true, if: :has_pixi?
  validates_datetime :alt_time, presence: true, unless: "alt_date.nil?"
  validates_datetime :appt_time, presence: true, unless: "appt_date.nil?"

  default_scope :order => "preferred_date, preferred_time ASC"

  # check if zip is in current service area
  def zip_service_area
    if PixiPostZip.find_by_zip(zip.to_i) == nil
       errors.add(:base, "Zip not in current PixiPost service area.")
    end
  end

  # checks if post has appointment & is completed
  def is_admin?
    has_appt? || is_completed?
  end

  # checks if post has pixan & is inot completed
  def can_set_appt?
    has_pixan? && !is_completed?
  end

  # set min start date
  def min_start_date
    Date.today + MIN_PPOST_DAYS.days
  end

  # set fields upon creation
  def set_flds
    self.status = 'active' if status.blank?
    self.status = 'scheduled' if has_appt? && !is_completed?
    self.status = 'completed' if is_completed?
  end

  # return active posts
  def self.active
    get_by_status 'active'
  end

  # get by seller
  def self.get_by_seller usr
    where(:user_id => usr)
  end

  # get by pixter
  def self.get_by_pixter usr
    where(:pixan_id => usr)
  end

  # return posts by status
  def self.get_by_status val
    includes(:user => [:pictures], :pixan => [:pictures]).where(:status => val)
  end

  # get pixter name
  def pixter_name
    pixan.name rescue nil
  end

  # get seller name
  def seller_name
    user.name rescue nil
  end

  # get seller first name
  def seller_first_name
    user.first_name rescue nil
  end

  # get seller email
  def seller_email
    user.email rescue nil
  end

  # check if invoice owner
  def owner? usr
    user_id == usr.id
  end

  # check if completed 
  def is_completed?
    !completed_date.blank?
  end

  # check if appt is made
  def has_appt?
    !appt_date.blank?
  end

  # check if address is populated
  def has_address?
    !address.blank? && !city.blank? && !state.blank? && !zip.blank?
  end

  # check if pixan is assigned
  def has_pixan?
    !pixan_id.blank?
  end

  # check if pixi is assigned
  def has_pixi?
    !pixi_id.blank?
  end

  # check if comments is assigned
  def has_comments?
    !comments.blank?
  end

  # load new pixi post with pre-populated fields
  def self.load_new usr, zip
    if usr
      pp = usr.pixi_posts.build
      if usr.has_address? && zip == usr.contacts[0].zip
        pp = AddressManager::synch_address pp, usr.contacts[0], false
      else
        loc = PixiPostZip.active.find_by_zip(zip.to_i) rescue nil
	pp.city, pp.state = loc.city, loc.state unless loc.blank?
        pp.mobile_phone, pp.home_phone = usr.contacts[0].mobile_phone, usr.contacts[0].home_phone unless usr.contacts[0].blank?
        pp.zip = zip
      end
    end
    pp
  end

  # display full address
  def full_address
    addr = AddressManager::full_address self
  end

  # format date
  def get_date method
    send(method).strftime("%m/%d/%Y") rescue nil
  end

  # format time
  def get_time method
    send(method).strftime("%l:%M %p") rescue nil
  end

  # cancels existing post and create new post based on original post
  def self.reschedule pid
    if old_post = PixiPost.where(id: pid).first
      attr = old_post.attributes  # copy attributes

      # remove protected attributes
      %w(id pixan_id appt_date appt_time preferred_date preferred_time alt_date alt_time comments pixi_id created_at updated_at)
      .map {|x| attr.delete x}

      # load attributes to new record
      new_post = PixiPost.new(attr)
       
      # remove old post
      old_post.destroy

      # return new post
      new_post
    else
      PixiPost.new
    end
  end

  # set json string
  def as_json(options={})
    super(except: [:updated_at], 
      methods: [:seller_name],
      include: {user: { only: [:first_name, :last_name], methods: [:photo] } })
  end


  # retrives the data for pixter_report
  def self.pixter_report start_date = DateTime.now - 30, end_date = DateTime.now, pixter_id = nil
    pixi_posts = Array.new
    if pixter_id == nil ? pixi_posts = PixiPost.all : pixi_posts = PixiPost.where(id: pixter_id)
    end
    pixi_posts = pixi_posts.keep_if{|elem| ((elem.status == "completed") &&
      (elem.completed_date >= start_date) && (elem.completed_date <= end_date))}
    pixi_posts
  end

end
