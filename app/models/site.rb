class Site < ActiveRecord::Base
  attr_accessible :email, :name, :org_type, :status, :institution_id, :pictures_attributes, :contacts_attributes, :url, :site_url
  attr_accessor :site_url

  before_create :set_flds
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

  validates :name, :presence => true

  default_scope :order => "name ASC"
  
  # select active sites and remove dups
  def self.active regionFlg=true
    where_stmt = regionFlg ? "status = 'active'" : "status = 'active' AND org_type NOT IN ('region', 'state', 'country')"
    where(where_stmt).sort_by { |e| e[:name] }.inject([]) { |m,e| m.last.nil? ? [e] : m.last[:name] == e[:name] ? m : m << e }
  end

  def set_flds
    SiteProcessor.new(self).set_flds
  end

  # select active sites w/ pixis
  def self.active_with_pixis
    SiteProcessor.new(self).active_with_pixis
  end

  # select by type
  def self.get_by_type val
    where("status = 'active' AND org_type = ?", val)
  end

  # select cities
  def self.cities
    get_by_type 'city'
  end

  # check if site is city
  def is_city?
    org_type == 'city'
  end

  # check if site is school
  def is_school?
    org_type == 'school'
  end

  # check if site is region
  def is_region?
    org_type == 'region'
  end

  # check if site is pub
  def is_pub?
    org_type == 'pub'
  end

  # check site type by id
  def self.check_site sid, val
    where(id: sid).check_org_type(val).first
  end

  # get site by id
  def self.get_site sid
    where(id: sid)
  end

  # check site type
  def self.check_org_type val
    where(org_type: val)
  end

  # get nearest region
  def self.get_nearest_region loc, range=60
    SiteProcessor.new(self).get_nearest_region loc, range
  end

  # select by name
  def self.get_by_name_and_type val, val1
    where("name = ?", val).get_by_type(val1)
  end

  # getter & setter for url
  def site_url
    SiteProcessor.new(self).site_url
  end

  def site_url=value
    self[:url] = SiteProcessor.new(self).generate_url value
  end

  # getter for local url
  def local_site_path
    SiteProcessor.new(self).local_site_path
  end

  # getter for http url string
  def url_str
    SiteProcessor.new(self).url_str
  end

  # return site by url
  def self.get_by_url val
    where("status = ? AND url = ?", 'active', val).first
  end

  # set json string
  def as_json(options={})
    super(only: [:id, :name])
  end
end
