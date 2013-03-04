class TempListing < ListingParent
  self.table_name = "temp_listings"

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true
end
