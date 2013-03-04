class Listing < ListingParent
  self.table_name = "listings"

  has_many :site_listings, :dependent => :destroy
  has_many :posts, :dependent => :destroy

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true
end
