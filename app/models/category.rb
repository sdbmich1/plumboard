class Category < ActiveRecord::Base
  attr_accessible :category_type, :name, :status, :pixi_type, :pictures_attributes

  has_many :subcategories
  has_many :listings
  has_many :temp_listings
  has_many :active_listings, class_name: 'Listing', conditions: { :status => 'active' }

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true, :reject_if => :all_blank

  validates :name, :presence => true
  validates :status, :presence => true
  validates :category_type, :presence => true
  validate :must_have_picture

  default_scope :order => "name ASC"

  # validate picture exists
  def must_have_picture
    if !any_pix?
      errors.add(:base, 'Must have a picture')
      false
    else
      true
    end
  end

  # used to add pictures for new category
  def with_picture
    self.pictures.build if self.pictures.blank?
    self
  end

  # check for a picture
  def any_pix?
    pictures.detect { |x| x && !x.photo_file_name.nil? }
  end

  # return active categories
  def self.active
    where(:status => 'active')
  end

  # return inactive categories
  def self.inactive
    where(:status => 'inactive')
  end

  # check if category is premium
  def premium?
    pixi_type == 'premium'  
  end

  # titleize name
  def name_title
    name.titleize rescue nil
  end

  # active listings by site
  def active_pixis_by_site loc
    loc.blank? ? active_listings : active_listings.where("site_id = ?", loc)
  end

  # check for subcategories
  def subcats?
    !subcategories.empty?
  end

  # set json string
  def as_json(options={})
    super(only: [:id, :name], methods: [:name_title])
  end
end
