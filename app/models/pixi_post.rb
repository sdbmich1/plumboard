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
  validates :home_phone, presence: true, length: {is: 10}
  validates :mobile_phone, allow_blank: true, length: {is: 10}
  validate :zip_service_area
  validates_date :preferred_date, presence: true, on_or_after: :today, unless: :has_appt?
  validates_date :alt_date, allow_blank: true, on_or_after: :today
  validates_date :appt_date, on_or_after: :today, presence: true, if: :has_pixan?
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

  # set fields upon creation
  def set_flds
    self.status = 'active' if status.blank?
    self.status = 'scheduled' if has_appt? && !is_completed?
    self.status = 'completed' if is_completed?
  end

  # return active posts
  def self.active
    where(:status => 'active')
  end

  # return posts by status
  def self.get_by_status val
    where(:status => val)
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

  # set json string
  def as_json(options={})
    super(except: [:updated_at], 
      methods: [:seller_name],
      include: {user: { only: [:first_name, :last_name], methods: [:photo] } })
  end
end
