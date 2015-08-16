class Site < ActiveRecord::Base
  attr_accessible :email, :name,  :status, :institution_id, :pictures_attributes, :contacts_attributes, :site_type_code

  has_many :site_users
  has_many :users, :through => :site_users

  has_many :listings, :dependent => :destroy
  has_many :active_listings, class_name: 'Listing', 
        conditions: proc { "'#{Date.today.to_s(:db)}' BETWEEN start_date AND end_date AND status = 'active'" }

  scope :with_pixis, :include    => :listings, 
                     :conditions => "listings.id IS NOT NULL"

  has_many :temp_listings, :dependent => :destroy
  scope :with_new_pixis, :include    => :temp_listings, 
                         :conditions => "temp_listings.id IS NOT NULL"

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  has_many :contacts, :as => :contactable, :dependent => :destroy
  accepts_nested_attributes_for :contacts, :allow_destroy => true



  belongs_to :site_type, primary_key: 'code', foreign_key: 'site_type_code'

  validates :name, :presence => true
  validates :site_type_code, :presence => true

  default_scope :order => "name ASC"
  
  # select active sites and remove dups
  def self.active regionFlg=true
    where_stmt = regionFlg ? "status = 'active'" : "status = 'active' AND site_type_code NOT IN ('region', 'state', 'country')"
    where(where_stmt).sort_by { |e| e[:name] }.inject([]) { |m,e| m.last.nil? ? [e] : m.last[:name] == e[:name] ? m : m << e }
  end

  # select active sites w/ pixis
  def self.active_with_pixis
    where(:id => Listing.active.map(&:site_id).uniq)
  end

  # select by type
  def self.get_by_type val
    where("status = 'active' AND site_type_code = ?", val)
  end

  def self.get_by_status val
    where("status = ?", val)
  end

  # select cities
  def self.cities
    get_by_type 'city'
  end

  # check if site is city
  def is_city?
    site_type_code == 'city'
  end

  # check if site is school
  def is_school?
    site_type_code == 'school'
  end

  # check if site is region
  def is_region?
    site_type_code == 'region'
  end

  # check site type by id
  def self.check_site sid, val
    where(id: sid).check_site_type_code(val).first
  end

  # get site by id
  def self.get_site sid
    where(id: sid)
  end

  # check site type
  def self.check_site_type_code val
    where(site_type_code: val)
  end

  # get nearest region
  def self.get_nearest_region loc, range=60
    unless site = Site.where(id: Contact.proximity(nil, range, loc, true)).get_by_type('region').first
      site = Site.where(name: PIXI_LOCALE).first
    end
    [site.id, site.name] rescue [0, loc]
  end

  # set json string
  def as_json(options={})
    super(only: [:id, :name])
  end
end
