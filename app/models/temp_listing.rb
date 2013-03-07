class TempListing < ListingParent
  self.table_name = "temp_listings"
   
  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  # set unique key
  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while TempListing.where(:pixi_id => token).exists?
    self.pixi_id = token
  end

  # submit order request
  def self.submit_order val
    tmp_listing = TempListing.find val rescue nil

    # check if parent exists (i.e. original pixi is already posted)
    tmp_listing.status = !tmp_listing.parent_pixi_id.blank? ? 'pending' : 'submitted' if tmp_listing
    tmp_listing
  end
end
