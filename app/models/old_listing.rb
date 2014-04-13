class OldListing < ListingParent
  self.table_name = "old_listings"

  attr_accessor :parent_pixi_id
end
