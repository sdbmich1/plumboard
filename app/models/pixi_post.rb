class PixiPost < ActiveRecord::Base
  resourcify

  before_save :set_flds
  after_commit :process_request, on: :create
  after_commit :send_appt_notice, on: :update

  attr_accessor :pixan_name, :work_phone, :listing_tokens
  attr_accessible :address, :alt_date, :alt_time, :city, :description, :pixan_id, :preferred_date, :preferred_time, :quantity, :state, 
    :user_id, :value, :zip, :status, :appt_time, :appt_date, :completed_date, :completed_time, :home_phone, :mobile_phone, :address2, 
    :comments, :editor_id, :pixan_name, :pixi_id, :country, :listing_tokens, :work_phone

  belongs_to :user
  belongs_to :pixan, foreign_key: "pixan_id", class_name: "User"
  has_many :pixi_post_details, dependent: :destroy
  has_many :listings, through: :pixi_post_details

  validates :user_id, presence: true
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 50, less_than_or_equal_to: MAX_PIXI_AMT.to_f }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :address, presence: true, length: {maximum: 50}
  validates :city, presence: true, length: {maximum: 30}
  validates :state, presence: true
  validates :zip, presence: true, length: {in: 5..10}
  validates :description, presence: true
  validates :preferred_time, presence: true
  validates :pixan_id, presence: true, if: :has_appt? || :is_completed?
  validates :home_phone, presence: true, length: {in: 10..15}
  validates :mobile_phone, allow_blank: true, length: {in: 10..15}
  validates :work_phone, allow_blank: true, length: {in: 10..15}
  validate :zip_service_area
  validates_date :preferred_date, presence: true, on_or_after: :min_start_date, unless: :is_admin?
  validates_date :alt_date, allow_blank: true, on_or_after: :min_start_date, unless: :is_admin?
  validates_date :appt_date, on_or_after: :today, presence: true, if: :can_set_appt?
  validates_date :completed_date, presence: true, if: :has_pixi?
  validates_datetime :alt_time, presence: true, unless: "alt_date.nil?"
  validates_datetime :appt_time, presence: true, unless: "appt_date.nil?"
  validate :must_have_pixis, unless: "completed_date.nil?"

  default_scope :order => "preferred_date, preferred_time ASC"

  # check if zip is in current service area
  def zip_service_area
    errors.add(:base, "Zip not in current PixiPost service area.") if PixiPostZip.find_by_zip(zip.to_i) == nil
  end

  # getter and setter for pixi_post_detail ids
  def listing_tokens
    pixi_post_details.pluck('pixi_id')
  end

  def listing_tokens=(pixi_ids)
    PixiPostProcessor.new(self).set_tokens pixi_ids
  end

  # checks if post has appointment & is completed
  def is_admin?
    has_appt? || is_completed?
  end

  # checks if post has pixan & is inot completed
  def can_set_appt?
    has_pixan? && !is_completed?
  end

  # validate picture exists
  def must_have_pixis
    if !has_pixi?
      errors.add(:base, 'Must have a pixi')
      false
    else
      true
    end
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
    !pixi_post_details.detect { |x| x && !x.pixi_id.nil? }.nil? 
  end

  # check if comments is assigned
  def has_comments?
    !comments.blank?
  end

  # load new pixi post with pre-populated fields
  def self.load_new usr, zip
    usr ? PixiPostProcessor.new(usr.pixi_posts.build).load_new(usr, zip) : PixiPost.new
  end

  # display full address
  def full_address
    PixiPostProcessor.new(self).full_address
  end

  # format date
  def get_date method
    send(method).strftime("%m/%d/%Y") rescue nil
  end

  # format time
  def get_time method
    send(method).strftime("%l:%M %p") rescue nil
  end

  # format date
  def format_date dt
    PixiPostProcessor.new(self).format_date(dt)
  end

  # cancels existing post and create new post based on original post
  def self.reschedule pid
    PixiPostProcessor.new(PixiPost.new).reschedule(pid)
  end

  # set json string
  def as_json(options={})
    super(except: [:updated_at], 
      methods: [:seller_name],
      include: {user: { only: [:first_name, :last_name], methods: [:photo] } })
  end

  # returns item title
  def self.item_title pixi_post
    pixi_post.pixi_post_details.first.pixi_title rescue nil
  end

  # returns item's sale value
  def self.sale_value pixi_post
    PixiPostProcessor.new(pixi_post).get_sale_value
  end

  # returns item's sale date
  def self.sale_date pixi_post
    PixiPostProcessor.new(pixi_post).get_sale_date
  end

  # returns item's listing value
  def self.listing_value pixi_post
    PixiPostProcessor.new(pixi_post).get_post_value
  end

  # retrives the data for pixter_report
  def self.pixter_report start_date, end_date, pixter_id
    PixiPostProcessor.new(PixiPost.new).pixter_report start_date, end_date, pixter_id
  end

  # post processing
  def process_request
    PixiPostProcessor.new(self).process_request
  end

  # post processing
  def send_appt_notice
    PixiPostProcessor.new(self).send_appt_notice
  end

  # migrate pixi id to details`
  def self.load_details
    PixiPostProcessor.new(self).load_details
  end

  def as_csv(options={})
    PixiPostProcessor.new(self).csv_data
  end

  # adds new record
  def self.add_post attr, usr
    PixiPostProcessor.new(PixiPost.new(attr)).add_post(usr)
  end

  def self.filename
    PixiPostProcessor.new(self).filename
  end
end
