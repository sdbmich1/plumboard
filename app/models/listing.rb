class Listing < ActiveRecord::Base
  attr_accessible :buyer_id, :category_type, :description, :title, :seller_id, :status, :price, :show_alias_flg, :show_phone_flg, :alias_name,
  	:org_id, :start_date, :end_date, :transaction_id

  belongs_to :user, :foreign_key => :seller_id
  belongs_to :organization, :foreign_key => :org_id
  belongs_to :transaction

  has_many :org_listings, :dependent => :destroy
  has_many :listing_categories, :dependent => :destroy
  has_many :posts, :dependent => :destroy

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  validates :title, :presence => true
  validates :description, :presence => true
  validates :seller_id, :presence => true
  validates :org_id, :presence => true
  validates :transaction_id, :presence => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
 
  default_scope :order => 'end_date DESC'

  def self.active
    where(:status=>'active')
  end
end
