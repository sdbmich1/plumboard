class Site < ActiveRecord::Base
  include ThinkingSphinx::Scopes
  
  attr_accessible :email, :name, :site_type_code, :status, :institution_id,
    :pictures_attributes, :contacts_attributes, :url, :site_url, :description
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



  belongs_to :site_type, primary_key: 'code', foreign_key: 'site_type_code'

  validates :name, :presence => true
  validates :site_type_code, :presence => true

  default_scope :order => "name ASC"
  
  # select active sites and remove dups
  def self.active regionFlg=true
    where_stmt = regionFlg ? "status = 'active'" : "status = 'active' AND site_type_code NOT IN ('region', 'state', 'country')"
    where(where_stmt).sort_by { |e| e[:name] }.inject([]) { |m,e| m.last.nil? ? [e] : m.last[:name] == e[:name] ? m : m << e }
  end

  def set_flds
    SiteProcessor.new(self).set_flds
  end

  # select active sites w/ pixis
  def self.active_with_pixis
    SiteProcessor.new(self).active_with_pixis
  end

  def self.inc_list
    includes(:pictures)
  end

  # select by type
  def self.get_by_type val, status='active'
    get_by_status(status).where("site_type_code = ?", val)
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

  # check if site is pub
  def is_pub?
    site_type_code == 'pub'
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
  def self.get_nearest_region loc
    SiteProcessor.new(self).get_nearest_region loc
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

  # check for a picture
  def any_pix?
    pictures.detect { |x| x && !x.photo_file_name.nil? }
  end

  # assign URL and save
  def save_site
    SiteProcessor.new(self).save_site
  end

  # add an optional second picture
  def with_picture
    pictures.build if pictures.blank? || pictures.size < 2
    self
  end

  # set json string
  def as_json(options={})
    super(only: [:id, :name])
  end

  sphinx_scope(:by_name) { |name|
    { conditions: { name: name } }
  }
end
