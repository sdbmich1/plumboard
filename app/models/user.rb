class User < ActiveRecord::Base
  include ThinkingSphinx::Scopes, Area
  extend Rolify
  rolify
  acts_as_reader

  # Include default devise modules. Others available are:
  devise :database_authenticatable, :async, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
  	 :token_authenticatable, :confirmable,
  	 :lockable, :timeoutable, :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :birth_date, :gender, :pictures_attributes,
    :fb_user, :provider, :uid, :contacts_attributes, :status, :acct_token, :preferences_attributes, :user_type_code, :business_name, :ref_id, :url,
    :user_url, :description, :active_listings_count, :cust_token, :ein, :ssn_last4, :active_card_accounts_count, :home_zip
  attr_accessor :user_url, :home_zip

  before_save :ensure_authentication_token, unless: :guest?
  before_create :set_flds
  after_commit :async_send_notification, :on => :create, unless: :guest?

  # define pixi relationships
  has_many :listings, foreign_key: :seller_id, dependent: :destroy
  has_many :active_listings, foreign_key: :seller_id, class_name: 'Listing', :conditions => "status = 'active' AND end_date >= curdate()"
  has_many :pixi_posted_listings, foreign_key: :seller_id, class_name: 'Listing', 
    :conditions => "status = 'active' AND end_date >= curdate() AND pixan_id IS NOT NULL"
  has_many :purchased_listings, foreign_key: :buyer_id, class_name: 'Listing', conditions: "status = 'sold'"
  has_many :sold_pixis, foreign_key: :seller_id, class_name: 'Listing', conditions: "status = 'sold'"
  has_many :new_pixis, foreign_key: :seller_id, class_name: 'TempListing', conditions: "status NOT IN ('approved', 'pending')"
  has_many :pending_pixis, foreign_key: :seller_id, class_name: 'TempListing', conditions: "status = 'pending'"
  has_many :temp_listings, foreign_key: :seller_id, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :pixi_likes, dependent: :destroy
  has_many :pixi_wants, dependent: :destroy
  has_many :pixi_asks, dependent: :destroy
  has_many :ship_addresses

  # define site relationships
  # has_many :site_users, :dependent => :destroy
  # has_many :sites, :through => :site_users

  # define user relationships
  belongs_to :user_type, primary_key: 'code', foreign_key: 'user_type_code'
  has_many :user_interests, :dependent => :destroy
  has_many :interests, :through => :user_interests
  has_many :user_pixi_points, dependent: :destroy

  # follow relationships
  has_many :favorite_sellers, foreign_key: 'user_id', dependent: :destroy
  has_many :sellers, through: :favorite_sellers, conditions: "favorite_sellers.status = 'active'"
  has_many :inverse_favorite_sellers, :class_name => "FavoriteSeller", :foreign_key => "seller_id"
  has_many :followers, :through => :inverse_favorite_sellers, :source => :user

  # define message relationships
  has_many :posts, dependent: :destroy
  has_many :incoming_posts, :foreign_key => "recipient_id", :class_name => "Post", :dependent => :destroy
  has_many :received_conversations, :foreign_key => "recipient_id", :class_name => "Conversation", :dependent => :destroy
  has_many :sent_conversations, :foreign_key => "user_id", :class_name => "Conversation", :dependent => :destroy

  # define invoice relationships
  has_many :invoices, foreign_key: :seller_id, dependent: :destroy
  has_many :unpaid_invoices, foreign_key: :seller_id, class_name: 'Invoice', conditions: "status = 'unpaid'"
  has_many :paid_invoices, foreign_key: :seller_id, class_name: 'Invoice', conditions: "status = 'paid'"
  has_many :received_invoices, :foreign_key => "buyer_id", :class_name => "Invoice"
  has_many :unpaid_received_invoices, foreign_key: :buyer_id, :class_name => "Invoice", conditions: "status = 'unpaid'"

  has_many :bank_accounts, dependent: :destroy
  has_many :active_bank_accounts, :class_name => "BankAccount", conditions: "status = 'active'"
  has_many :card_accounts, dependent: :destroy
  has_many :active_card_accounts, :class_name => "CardAccount", conditions: "status = 'active'"
  has_many :transactions, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :seller_ratings, :foreign_key => "seller_id", :class_name => "Rating"

  has_many :pixi_posts, dependent: :destroy
  has_many :active_pixi_posts, class_name: 'PixiPost', :conditions => "status = 'active'"
  has_many :pixan_pixi_posts, :foreign_key => "pixan_id", :class_name => "PixiPost"

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true, :reject_if => :all_blank

  has_many :contacts, :as => :contactable, :dependent => :destroy
  accepts_nested_attributes_for :contacts, :allow_destroy => true, :reject_if => :all_blank

  has_many :preferences, :dependent => :destroy
  accepts_nested_attributes_for :preferences, :allow_destroy => true, :reject_if => :all_blank

  # name format validators
  name_regex = 	/^[A-Z]'?['-., a-zA-Z]+$/i

  # validate added fields  				  
  validates :first_name,  :presence => true, :length => { :maximum => 30 }, :format => { :with => name_regex }, unless: :guest?  
  validates :last_name,  :presence => true, :length => { :maximum => 30 }, :format => { :with => name_regex }, unless: :guest?    
  validates_confirmation_of :password, if: :revalid
  validates :business_name,  :presence => true, :length => { :maximum => 60 }, if: :is_business?
  validates :birth_date,  :presence => true, unless: :guest_or_other?
  validates :gender,  :presence => true, unless: :guest_or_other?
  # validates :url, :presence => {:on => :create}, uniqueness: true, length: { :minimum => 2 }, unless: :guest?
  validate :must_have_picture, if: :is_business?
  validate :must_have_zip, unless: :guest?
  validates :ein, allow_blank: true, length: {is: 9}
  validates :ssn_last4, allow_blank: true, length: {is: 4}

  # validate picture exists
  def must_have_picture
    UserProcessor.new(self).must_have_picture
  end

  # validate zip exists
  def must_have_zip
    UserProcessor.new(self).must_have_zip
  end

  # get home zip
  def home_zip
    self.preferences.build if self.preferences.blank?
    preferences[0].zip
  end

  # set home zip
  def home_zip=(val)
    self.preferences.build if self.preferences.blank?
    preferences[0].zip = val
  end

  # getter & setter for url
  def user_url
    UserProcessor.new(self).user_url
  end

  def user_url=value
    self[:url] = UserProcessor.new(self).generate_url value 
  end

  # getter for local url
  def local_user_path
    UserProcessor.new(self).local_user_path
  end

  # getter for http url string
  def url_str
    UserProcessor.new(self).url_str
  end

  # used to add pictures for new user
  def with_picture
    UserProcessor.new(self).with_picture
  end

  # used to add pictures for new user
  def biz_with_picture
    self.user_type_code = 'BUS'
    UserProcessor.new(self).with_picture(false)
  end

  # return active types
  def self.active
    includes(:pictures).where(:status => 'active')
  end

  # eager load associations
  def self.find_user uid
    includes(:pixi_posted_listings, :pixi_wants, :pixi_likes, :pixi_asks,
      :bank_accounts, :card_accounts, :transactions, :ratings, :seller_ratings, :inquiries, :comments,
      :posts, :incoming_posts, :pixi_posts, :active_pixi_posts, :pixan_pixi_posts, :saved_listings, 
      :pictures, :contacts, :preferences, :user_pixi_points, 
      :listings => :pictures, :active_listings => :pictures, :sold_pixis => :pictures, :temp_listings => :pictures, 
      :purchased_listings => :pictures, :pending_pixis => :pictures, :new_pixis => :pictures).where(id: uid).first 
  end

  # check for a picture
  def any_pix?
    pictures.detect { |x| x && !x.photo_file_name.nil? }
  end

  # combine name
  def name
    is_business? ? business_name : [first_name, last_name].join(" ")
  end

  # abbreviated name
  def abbr_name
    [first_name, last_name[0]].join " "
  end

  # return all pixis for user
  def pixis
    self.active_listings rescue nil
  end

  # get pixi count
  def pixi_count
    active_listings_count rescue 0
  end

  # get ratings count
  def rating_count
    seller_ratings.size rescue 0
  end

  # return whether user has pixis
  def has_pixis?
    pixi_count > 0 rescue nil
  end

  # return whether user has any bank accounts
  def has_bank_account?
    Rails.logger.info(active_bank_accounts)    # remove after upgrading past Rails 4.1.1
    active_bank_accounts.size > 0 rescue nil
  end

  # return whether user has any card accounts
  def has_card_account?
    Rails.logger.info(active_card_accounts)    # remove after upgrading past Rails 4.1.1
    active_card_accounts.size > 0 rescue nil
  end

  # return any valid card 
  def get_valid_card
    mo, yr = Date.today.month, Date.today.year
    active_card_accounts.detect { |x| x.expiration_year > yr || (x.expiration_year == yr && x.expiration_month >= mo) }
  end

  # process facebook user
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    UserProcessor.new(self).load_facebook_user access_token, signed_in_resource
  end

  # add photo from url
  def self.picture_from_url usr, access_token
    UserProcessor.new(self).add_url_image(usr, access_token)
  end

  # add guest account
  def self.new_guest
    create { |u| u.guest = true; u.provider = 'pxb'; u.status = 'inactive'; u.email = "guest#{DateTime.now.to_i}@pxbguest.com" }
  end

  # devise user handler
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  # verify if user is active
  def active?
    status == 'active'
  end

  # used to bypass devise validations for facebook users
  def password_required?
    super && provider.blank?
  end

  def confirmation_required?
    super && provider.blank?
  end

  def revalid
    false
  end

  # set account to inctive status
  def deactivate
    self.status = 'inactive'
    self
  end

  # display image for user
  def photo num=0, sz='tiny'
    PictureProcessor.new(self.pictures[num]).get_pixi_image(sz) rescue nil
  end

  def photo_url
    photo 0, 'medium'
  end

  def cover_photo
    photo 1, 'cover'
  end

  # check if address is populated
  def has_address?
    UserProcessor.new(self).has_address?
  end

  # check if prefs are populated
  def has_prefs?
    UserProcessor.new(self).has_prefs?
  end

  # gets primary address
  def primary_address
    contacts.first.full_address rescue nil
  end

  # display image with name for autocomplete
  def pic_with_name
    UserProcessor.new(self).pic_with_name
  end

  # display image with name for autocomplete
  def pic_with_business_name
    UserProcessor.new(self).pic_with_business_name
  end

  # return any unpaid invoices count 
  def unpaid_invoice_count
    Rails.logger.info(unpaid_received_invoices)    # remove after upgrading past Rails 4.1.1
    unpaid_received_invoices.size
  end

  # return whether user has any unpaid invoices 
  def has_unpaid_invoices?
    unpaid_invoice_count > 0
  end

  # get number of unread messages for user
  def unread_count
    UserProcessor.new(self).unread_count
  end

  # new user?
  def new_user?
    sign_in_count == 1 rescue nil
  end

  # format birth date
  def birth_dt
    birth_date.strftime('%m/%d/%Y') rescue nil
  end

  # convert date/time display
  def nice_date(tm, tmFlg=true)
    UserProcessor.new(self).nice_date tm, tmFlg
  end

  # define include list
  def self.include_list
    includes(:pictures, :preferences, :user_type)
  end

  # return users by type
  def self.get_by_type val
    UserProcessor.new(self).get_by_type val
  end

  # return user by url
  def self.get_by_url val
    active.where(:url => val).first
  end
  
  # check user is pixter
  def is_pixter?
    code_type == 'PT' rescue false
  end
  
  # check user is member
  def is_member?
    code_type == 'MBR' rescue false
  end
  
  # check user is business
  def is_business?
    code_type == 'BUS' rescue false
  end
  
  # check user is support
  def is_support?
    code_type == 'SP' rescue false
  end
  
  # check user is admin
  def is_admin?
    code_type == 'AD' rescue false
  end

  # check if user (a seller) is being followed by user_id
  def is_followed?(user_id)
    followers.where("favorite_sellers.status = 'active'").exists?(id: user_id)
  end

  # check if user is following seller_id
  def is_following?(seller_id)
    favorite_sellers.where(status: 'active').exists?(seller_id: seller_id)
  end

  # toggle between seller and user (follower)
  def self.get_by_ftype(ftype, id, status)
    ftype == 'seller' ? UserProcessor.new(nil).get_by_seller(id, status) : UserProcessor.new(nil).get_by_user(id, status)
  end

  def get_follow_status(ftype, id)
    result = ftype == 'seller' ? is_following?(id) : is_followed?(id)
    result ? 'active' : 'inactive'
  end

  # return the date the current user followed seller_id
  def date_followed(seller_id)
    UserProcessor.new(self).date_followed(seller_id)
  end

  # return the ID of the FavoriteSeller object for the current user and seller_id
  def favorite_seller_id(seller_id)
    UserProcessor.new(self).favorite_seller_id(seller_id)
  end

  # display user type
  def type_descr
    user_type.description rescue nil
  end

  # display user type code
  def code_type
    user_type_code.upcase rescue 'MBR'
  end

  # get site name
  def site_name
    UserProcessor.new(self).site_name
  end

  # send notice & add points
  def async_send_notification
    UserProcessor.new(self).process_data
  end

  def value
    self.name
  end

  def rating
    UserProcessor.new(self).get_rating
  end

  # set json string
  def as_json(options={})
    super(only: [:id, :first_name, :last_name, :email, :birth_date, :gender, :current_sign_in_ip, :fb_user, :business_name, :url, 
        :description, :cust_token], 
      methods: [:name, :photo, :photo_url, :unpaid_invoice_count, :pixi_count, :unread_count, :birth_dt, :home_zip, :value, :site_name,
        :cover_photo, :rating], 
      include: {unpaid_received_invoices: {except: [:created_at, :updated_at]}, contacts: {except: [:created_at, :updated_at]}, 
        active_bank_accounts: {except: [:created_at, :updated_at]}, active_card_accounts: {except: [:created_at, :updated_at]}, 
        sellers: {only: [:id, :business_name]}, ship_addresses: { except: [:created_at, :updated_at], methods: [:recipient_name], 
	  include: {contacts: {except: [:created_at, :updated_at]}}}})
  end

  # get user conversations
  def get_conversations
    sent_conversations + received_conversations rescue nil
  end

  # determine age
  def age
    UserProcessor.new(self).calc_age
  end    

  # check user type is business
  def is_business?
    code_type == 'BUS' rescue false
  end

  # check if guest or non-person
  def guest_or_other?
    is_business? || guest?
  end

  # check if guest or test
  def guest_or_test?
    Rails.env.test? || guest?
  end

  # moves data from guest to actute user
  def move_to usr
    UserProcessor.new(self).move_to usr
  end

  # set key fields on save
  def set_flds
    UserProcessor.new(self).set_flds
  end

  # get active sellers
  def self.get_sellers listings
    UserProcessor.new(self).get_sellers listings
  end

  def as_csv(options={})
    UserProcessor.new(self).csv_data
  end

  def self.filename utype
    UserProcessor.new(self).filename utype
  end

  def self.board_fields
    select('users.id, users.business_name, users.url, users.user_type_code')
  end

  def has_ship_address?
    Rails.logger.info(ship_addresses)    # remove after upgrading past Rails 4.1.1
    ship_addresses.size > 0
  end

  # set sphinx scopes
   sphinx_scope(:first_name) { 
     {:order => 'first_name, last_name ASC'}
  }  

  sphinx_scope(:by_email) { |email|
    {:conditions => {:email => email}}
  }
end
