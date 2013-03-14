class TempListing < ListingParent
  self.table_name = "temp_listings"
   
  before_create :set_flds

  has_many :site_listings, :foreign_key => :listing_id, :dependent => :destroy
  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, allow_destroy: true, reject_if: lambda { |t| t['picture'].nil? && !t['id'].blank? }

  # set unique key
  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while TempListing.where(:pixi_id => token).exists?
    self.pixi_id = token
  end

  # set fields upon creation
  def set_flds
    # generate unique pixi key
    generate_token

    self.status = 'new' if self.status.blank?
    self.alias_name = rand(36**ALIAS_LENGTH).to_s(36) if alias?
    set_end_date
  end

  # submit order request
  def self.submit_order val
    tmp_listing = TempListing.find val rescue nil

    # check if parent exists (i.e. original pixi is already posted)
    tmp_listing.status = !tmp_listing.parent_pixi_id.blank? ? 'pending' : 'submitted' if tmp_listing
    tmp_listing
  end
end
