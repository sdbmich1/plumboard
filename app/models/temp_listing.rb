class TempListing < ListingParent
  self.table_name = "temp_listings"
  resourcify

  belongs_to :user, foreign_key: :seller_id

  before_create :set_flds
  after_commit :async_send_notification, :on => :update

  attr_accessor :slr_name
  attr_accessible :slr_name, :item_color, :item_id, :car_color, :car_id, :location_size, :product_size

  default_scope :order => "temp_listings.updated_at DESC"

  # set fields upon creation
  def set_flds
    TempListingProcessor.new(self).set_flds
  end

  # getter & setter for shared color & other_id fields
  def item_color
    self[:color] unless is_category_type?('vehicle')
  end

  def item_color=value
    self[:color] = value unless is_category_type?('vehicle')
  end

  def item_id
    self[:other_id] unless is_category_type?('vehicle')
  end

  def item_id=value
    self[:other_id] = value unless is_category_type?('vehicle')
  end

  def car_color
    self[:color] if is_category_type?('vehicle')
  end

  def car_color=value
    self[:color] = value if is_category_type?('vehicle')
  end

  def car_id
    self[:other_id] if is_category_type?('vehicle')
  end

  def car_id=value
    self[:other_id] = value if is_category_type?('vehicle')
  end

  def location_size
    self[:item_size] if is_category_type?('housing')
  end

  def location_size=value
    self[:item_size] = value if is_category_type?('housing')
  end

  def product_size
    self[:item_size] if is_category_type?('product')
  end

  def product_size=value
    self[:item_size] = value if is_category_type?('product')
  end

  # sets values from assessor fields to table fields
  def set_item_flds
    self.color, self.other_id, self.item_size = item_color || car_color, item_id || car_id, location_size || product_size
  end

  # finds specific pixi
  def self.find_pixi pid
    includes(:pictures, :category, :user=>[:pictures]).where(pixi_id: pid).first
  end

  # approve order
  def approve_order usr
    edit_flds usr, 'approved' if usr
  end

  # deny order
  def deny_order usr, reason=''
    edit_flds usr, 'denied', reason if usr
  end

  # edit order fields to process order
  def edit_flds usr, val, reason=''
    TempListingProcessor.new(self).edit_flds usr, val, reason
  end

  # check if pixi is free
  def free?
    TempListingProcessor.new(self).free?
  end

  # submit order request for review
  def submit_order val
    TempListingProcessor.new(self).submit_order val
  end

  # used to resubmit changes to previously approved orders for new approval
  def resubmit_order
    submit_order transaction_id
  end

  # find pixis in draft status
  def self.draft
    include_list.where("status NOT IN ('approved', 'pending')").reorder('temp_listings.updated_at DESC')
  end

  # add listing to board and process transaction
  def async_send_notification 
    TempListingProcessor.new(self).async_send_notification
  end

  # set deny item list based on pixi type
  def deny_item_list
    ['Bad Pictures', 'Improper Content', 'Insufficient Information']
  end

  # adds new record
  def self.add_listing attr, usr
    TempListingProcessor.new(TempListing.new(attr)).add_listing(usr)
  end
end
