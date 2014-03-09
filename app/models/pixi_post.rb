class PixiPost < ActiveRecord::Base
  resourcify
  before_save :set_flds

  attr_accessor :pixan_name
  attr_accessible :address, :alt_date, :alt_time, :city, :description, :pixan_id, :preferred_date, :preferred_time, :quantity, :state, 
    :user_id, :value, :zip, :status, :appt_time, :appt_date, :completed_date, :completed_time, :home_phone, :mobile_phone, :address2, 
    :comments, :editor_id, :pixan_name, :pixi_id, :country

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :pixan, foreign_key: "pixan_id", class_name: "User"

  validates :user_id, presence: true
  validates :preferred_time, presence: true
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 50 }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :address, presence: true, length: {maximum: 50}
  validates :city, presence: true, length: {maximum: 30}
  validates :state, presence: true
  validates :zip, presence: true, length: {minimum: 5, maximum: 12}
  validates :description, presence: true
  validates_date :preferred_date, presence: true, on_or_after: :today, unless: :has_appt?
  validates_date :alt_date, allow_blank: true, on_or_after: :today
  validates_date :appt_date, on_or_after: :today, presence: true, if: :has_pixan?
  validates_date :completed_date, on_or_after: :today, presence: true, if: :has_pixi?
  validates :pixan_id, presence: true, if: :has_appt? || :is_completed?
  validates :pixi_id, presence: true, unless: "completed_date.nil?"

  default_scope :order => "preferred_date, preferred_time ASC"

  # set fields upon creation
  def set_flds
    self.status = 'active' if self.status.blank?
    self.status = 'scheduled' if has_appt? && !is_completed?
    self.status = 'completed' if is_completed?
  end

  # return active categories
  def self.active
    where(:status => ['active', 'scheduled'])
  end

  # get seller name for a listing
  def seller_name
    user.name rescue nil
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
  def self.load_new usr
    if usr
      pp = usr.pixi_posts.build
      if usr.contacts[0]
        pp.address, pp.address2 = usr.contacts[0].address, usr.contacts[0].address2
        pp.city, pp.state = usr.contacts[0].city, usr.contacts[0].state
        pp.zip, pp.home_phone = usr.contacts[0].zip, usr.contacts[0].home_phone
        pp.mobile_phone = usr.contacts[0].mobile_phone
      end
    end
    pp
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
