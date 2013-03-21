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

  # approve order
  def approve_order usr
    edit_flds usr, 'approved' if usr
  end

  # deny order
  def deny_order usr
    edit_flds usr, 'denied' if usr
  end

  # edit order fields to process order
  def edit_flds usr, val
    self.status = val
    self.edited_by = usr.name
    self.edited_dt = Time.now
    save!
  end

  # submit order request for review
  def submit_order val

    # set transaction id
    if val
      self.transaction_id = val
      self.status = 'pending' 
      save!
    else
      false
    end
  end

  # add listing to post if approved
  def post_to_board
    if self.status == 'approved'
      listing = Listing.new self.attributes

      # add photos
      self.pictures.each do |pic|
        listing.pictures.build(:photo => pic.photo)
      end

      # add to board
      listing.save!
    else
      false
    end
  end
end
