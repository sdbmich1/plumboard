class OldListing < ListingParent
  self.table_name = "old_listings"

  attr_accessor :parent_pixi_id
  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, allow_destroy: true, reject_if: :all_blank, limit: MAX_PIXI_PIX 
end
