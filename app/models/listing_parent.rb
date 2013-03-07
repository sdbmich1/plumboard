class ListingParent < ActiveRecord::Base
  self.abstract_class = true

  before_create :set_flds

  # load pixi config keys
  ALIAS_LENGTH = PIXI_KEYS['pixi']['alias_length']
  KEY_LENGTH = PIXI_KEYS['pixi']['key_length']

  attr_accessible :buyer_id, :category_id, :description, :title, :seller_id, :status, :price, :show_alias_flg, :show_phone_flg, :alias_name,
  	:site_id, :start_date, :end_date, :transaction_id, :pictures_attributes, :pixi_id, :parent_pixi_id

  belongs_to :user, :foreign_key => :seller_id
  belongs_to :site
  belongs_to :category
  has_one :transaction

  validates :title, :presence => true, :length => { :maximum => 80 }
  validates :description, :presence => true
  validates :seller_id, :presence => true
  validates :site_id, :presence => true
  validates :start_date, :presence => true
  validates :category_id, :presence => true
  validates :price, :numericality => true, :allow_blank => true
  validate :must_have_pictures

  default_scope :order => 'end_date DESC'

  # validate existance of at least one picture
  def must_have_pictures
    errors.add(:base, 'Must have at least one picture') if pictures.all?(&:marked_for_destruction?)
  end

  # select active listings
  def self.active
    where(:status=>'active')
  end

  # find listings by status
  def self.get_by_status val
    where(:status => val)
  end

  # find listings by site id
  def self.get_by_site val
    where(:site_id => val)
  end

  # find listings by seller user id
  def self.get_by_seller val
    where(:seller_id => val)
  end

  # set fields upon creation
  def set_flds
    generate_token
    self.status = 'new' if self.status.blank?
    self.alias_name = rand(36**ALIAS_LENGTH).to_s(36) if alias?
    set_end_date
  end

  # activate listing to display on network
  def activate
    if self.status != 'sold'
      self.status, self.start_date = 'active', Time.now 
      set_end_date
    end
    self
  end

  # verify if listing has been paid for
  def has_transaction?
    !transaction_id.blank?
  end

  # verify if listing is active
  def active?
    status == 'active'
  end

  # verify if alias is used
  def alias?
    show_alias_flg == 'yes'
  end

  # verify if current user is listing seller
  def seller? uid
    seller_id == uid
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
    description[0..29] rescue nil
  end

  # set end date to x days after start to denote when listing is no longer displayed on network
  def set_end_date
    self.end_date = self.start_date + 7.days
  end
end
