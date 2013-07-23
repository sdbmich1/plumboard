class TempListing < ListingParent
  self.table_name = "temp_listings"

  include CalcTotal
   
  before_create :set_flds

  has_many :site_listings, :foreign_key => :listing_id, :dependent => :destroy
  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, allow_destroy: true, reject_if: :all_blank, limit: MAX_PIXI_PIX 

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

  # check if pixi is free
  def free?
    CalcTotal::get_price(self.premium?) == 0.00
  end

  # submit order request for review
  def submit_order val

    # set transaction id
    if val || free?
      self.transaction_id = val if val
      self.status = 'pending' 
      save!
    else
      errors.add :base, "Pixi must have transaction to submit an order."
      false
    end
  end

  # used to resubmit changes to previously approved orders for new approval
  def resubmit_order
    submit_order transaction_id
  end

  # add listing to post if approved
  def post_to_board
    if self.status == 'approved'
      unless listing = Listing.where(:pixi_id => self.pixi_id).first
        # copy attributes
	attr = self.attributes

	# remove protected attributes
	%w(id created_at updated_at).map {|x| attr.delete x}

	# load attributes to new record
        listing = Listing.new attr
      end

      # add photos
      self.pictures.each do |pic|
        listing.pictures.build(:photo => pic.photo)
      end

      # add to board
      listing.save!
    else
      errors.add :base, "Pixi must be approved prior to posting to board."
      false
    end
  end

  # delete selected photo
  def delete_photo pid
    # find selected photo
    pic = self.pictures.find pid

    # remove photo if found and not only photo for listing
    result = pic && self.pictures.size > 1 ? self.pictures.delete(pic) : false

    # add error msg
    errors.add :base, "Pixi must have at least one image." unless result
    result
  end
end
