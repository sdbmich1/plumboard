class Listing < ActiveRecord::Base
  before_create :set_flds

  attr_accessible :buyer_id, :category_id, :description, :title, :seller_id, :status, :price, :show_alias_flg, :show_phone_flg, :alias_name,
  	:site_id, :start_date, :end_date, :transaction_id, :pictures_attributes

  belongs_to :user, :foreign_key => :seller_id
  belongs_to :site
  has_one :transaction

  has_many :site_listings, :dependent => :destroy
  has_many :listing_categories, :dependent => :destroy
  has_many :posts, :dependent => :destroy

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  validates :title, :presence => true
  validates :description, :presence => true
  validates :seller_id, :presence => true
  validates :site_id, :presence => true
  validates :start_date, :presence => true
  validates :category_id, :presence => true
#  validates :end_date, :presence => true
#  validates :transaction_id, :presence => true
 
  default_scope :order => 'end_date DESC'

  def self.active
    where(:status=>'active')
  end

  def self.get_by_site val
    active.where(:site_id => val)
  end

  def self.get_by_seller val
    where(:seller_id => val)
  end

  def set_flds
    self.end_date = self.start_date + 7.days
    self.status = 'active'
  end
end
