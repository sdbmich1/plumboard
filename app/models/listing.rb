class Listing < ListingParent
  self.table_name = "listings"

  attr_accessor :parent_pixi_id

  has_many :site_listings, :dependent => :destroy
  has_many :posts, :dependent => :destroy

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true

  # set unique key
  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while Listing.where(:pixi_id => token).exists?
    self.pixi_id = token
  end
end
