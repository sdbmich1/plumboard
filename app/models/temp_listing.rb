class TempListing < ListingParent
  self.table_name = "temp_listings"
  resourcify

  include CalcTotal, SystemMessenger
  before_create :set_flds
  after_commit :async_send_notification, :on => :update

  attr_accessor :slr_name
  attr_accessible :slr_name
  has_many :site_listings, :foreign_key => :listing_id, :dependent => :destroy

  # set unique key
  def generate_token
    begin
      token = SecureRandom.urlsafe_base64
    end while TempListing.where(:pixi_id => token).exists?

    self.pixi_id = token
  end

  # set fields upon creation
  def set_flds
    # parse non-ascii chars
    encoding_options = {:invalid => :replace, :undef => :replace, :replace => '', :UNIVERSAL_NEWLINE_DECORATOR => true}
    self.title.encode!(Encoding.find('ASCII'), encoding_options)
    self.description.encode!(Encoding.find('ASCII'), encoding_options)

    # set as new if empty
    self.status = 'new' if status.blank?

    # generate unique pixi key
    generate_token if pixi_id.blank?

    self.alias_name = rand(36**ALIAS_LENGTH).to_s(36) if alias?
    set_end_date
    self
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
  def deny_order usr, reason
    edit_flds usr, 'denied', reason if usr
  end

  # edit order fields to process order
  def edit_flds usr, val, reason=''
    self.status, self.edited_by, self.edited_dt, self.explanation = val, usr.name, Time.now, reason
    save!
  end

  # check if pixi is free
  def free?
    CalcTotal::get_price(self.premium?) == 0.00 rescue true
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

  # add listing to board if approved
  def post_to_board
    if self.status == 'approved'
      dup_pixi true
    else
      errors.add :base, "Pixi must be approved prior to posting to board."
      false
    end
  end

  # find listings by site id
  def self.get_by_site val
    where(:site_id => val)
  end

  # find pixis in draft status
  def self.draft
    include_list.where("status NOT IN ('approved', 'pending')").reorder('temp_listings.updated_at DESC')
  end

  # add listing to board and process transaction
  def async_send_notification 
    case status
      when 'pending'
        UserMailer.delay.send_submit_notice(self)
      when 'approved'
        post_to_board
        transaction.process_transaction unless transaction.approved? rescue nil
      when 'denied'
        # pxb notice & email messages to user
        UserMailer.delay.send_denial(self)
        SystemMessenger::send_message user, self, 'deny'
    end
  end
end
