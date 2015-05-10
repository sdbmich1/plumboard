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
    :user_url
  attr_accessor :user_url

  before_save :ensure_authentication_token, unless: :guest_or_test?
  after_commit :async_send_notification, :on => :create, unless: :guest?

  # define pixi relationships
  has_many :listings, foreign_key: :seller_id, dependent: :destroy
  has_many :active_listings, foreign_key: :seller_id, class_name: 'Listing', :conditions => "status = 'active' AND end_date >= curdate()"
  has_many :pixi_posted_listings, foreign_key: :seller_id, class_name: 'Listing', 
    :conditions => "status = 'active' AND end_date >= curdate() AND pixan_id IS NOT NULL"
  has_many :purchased_listings, foreign_key: :buyer_id, class_name: 'Listing', conditions: { :status => 'sold' }
  has_many :sold_pixis, foreign_key: :seller_id, class_name: 'Listing', conditions: { :status => 'sold' }
  has_many :new_pixis, foreign_key: :seller_id, class_name: 'TempListing', conditions: "status NOT IN ('approved', 'pending')"
  has_many :pending_pixis, foreign_key: :seller_id, class_name: 'TempListing', conditions: { :status => 'pending' }
  has_many :temp_listings, foreign_key: :seller_id, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :pixi_likes, dependent: :destroy
  has_many :pixi_wants, dependent: :destroy
  has_many :pixi_asks, dependent: :destroy

  # define site relationships
  # has_many :site_users, :dependent => :destroy
  # has_many :sites, :through => :site_users

  # define user relationships
  belongs_to :user_type, primary_key: 'code', foreign_key: 'user_type_code'
  has_many :user_interests, :dependent => :destroy
  has_many :interests, :through => :user_interests
  has_many :user_pixi_points, dependent: :destroy

  # define message relationships
  has_many :posts, dependent: :destroy
  has_many :incoming_posts, :foreign_key => "recipient_id", :class_name => "Post", :dependent => :destroy
  has_many :received_conversations, :foreign_key => "recipient_id", :class_name => "Conversation", :dependent => :destroy
  has_many :sent_conversations, :foreign_key => "user_id", :class_name => "Conversation", :dependent => :destroy

  # define invoice relationships
  has_many :invoices, foreign_key: :seller_id, dependent: :destroy
  has_many :unpaid_invoices, foreign_key: :seller_id, class_name: 'Invoice', conditions: { :status => 'unpaid' }
  has_many :paid_invoices, foreign_key: :seller_id, class_name: 'Invoice', conditions: { :status => 'paid' }
  has_many :received_invoices, :foreign_key => "buyer_id", :class_name => "Invoice"
  has_many :unpaid_received_invoices, foreign_key: :buyer_id, :class_name => "Invoice", conditions: { :status => 'unpaid' }

  has_many :bank_accounts, dependent: :destroy
  has_many :card_accounts, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :inquiries, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :seller_ratings, :foreign_key => "seller_id", :class_name => "Rating"

  has_many :pixi_posts, dependent: :destroy
  has_many :active_pixi_posts, class_name: 'PixiPost', :conditions => { :status => 'active' }
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
  validates :business_name,  :presence => true, :length => { :maximum => 60 }, :format => { :with => name_regex }, if: :is_business? 
  validates :birth_date,  :presence => true, unless: :guest_or_other?
  validates :gender,  :presence => true, unless: :guest_or_other?
  # validates :url, :presence => {:on => :create}, uniqueness: true, length: { :minimum => 2 }, unless: :guest?
  validate :must_have_picture, unless: :guest?
  validate :must_have_zip, unless: :guest?

  # validate picture exists
  def must_have_picture
    if !any_pix?
      errors.add(:base, 'Must have a picture')
      false
    else
      true
    end
  end

  # validate zip exists
  def must_have_zip
    if provider.blank?
      if !home_zip.blank? && (home_zip.length == 5 && home_zip.to_region) 
        true
      else
        errors.add(:base, 'Must have a valid zip')
        false
      end
    else
      true
    end
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
    self[:url] 
  end

  def user_url=value
    self[:url] = UserProcessor.new(self).generate_url value 
  end

  # used to add pictures for new user
  def with_picture
    self.pictures.build if self.pictures.blank?
    self.preferences.build if self.preferences.blank?
    self
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
    pixis.size rescue 0
  end

  # return whether user has pixis
  def has_pixis?
    pixi_count > 0 rescue nil
  end

  # return whether user has any bank accounts
  def has_bank_account?
    bank_accounts.size > 0 rescue nil
  end

  # return whether user has any card accounts
  def has_card_account?
    card_accounts.size > 0 rescue nil
  end

  # return any valid card 
  def get_valid_card
    mo, yr = Date.today.month, Date.today.year
    card_accounts.detect { |x| x.expiration_year > yr || (x.expiration_year == yr && x.expiration_month >= mo) }
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
  def photo
    self.pictures[0].photo.url(:tiny) rescue nil
  end

  # check if address is populated
  def has_address?
    UserProcessor.new(self).has_address?
  end

  # display image with name for autocomplete
  def pic_with_name
    pic = self.photo rescue nil
    pic ? "<img src='#{pic}' class='inv-pic' /> #{self.name}" : nil
  end

  # return any unpaid invoices count 
  def unpaid_invoice_count
    unpaid_received_invoices.size rescue 0
  end

  # return whether user has any unpaid invoices 
  def has_unpaid_invoices?
    unpaid_invoice_count > 0 rescue nil
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
  def nice_date(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y %l:%M %p') rescue nil
  end

  # define include list
  def self.include_list
    includes(:pictures, :preferences)
  end

  # return users by type
  def self.get_by_type val
    val.blank? ? all : where(:user_type_code => val)
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
    user_type_code.upcase == 'BUS' rescue false
  end
  
  # check user is support
  def is_support?
    code_type == 'SP' rescue false
  end
  
  # check user is admin
  def is_admin?
    code_type == 'AD' rescue false
  end

  # display user type
  def type_descr
    user_type.description rescue nil
  end

  # display user type code
  def code_type
    user_type_code.upcase rescue 'MBR'
  end

  # send notice & add points
  def async_send_notification
    UserProcessor.new(self).process_data
  end

  # set json string
  def as_json(options={})
    super(only: [:id, :first_name, :last_name, :email, :birth_date, :gender, :current_sign_in_ip, :fb_user, :business_name], 
          methods: [:name, :photo, :unpaid_invoice_count, :pixi_count, :unread_count, :birth_dt, :home_zip], 
          include: {active_listings: {}, unpaid_received_invoices: {}, bank_accounts: {}, contacts: {}, card_accounts: {}})
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
    user_type_code == 'BUS' rescue false
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

  def set_flds
    user_url = name unless guest?
  end

  def as_csv(options={})
    { "Name" => name, "Email" => email, "Home Zip" => home_zip, "Birth Date" => birth_dt, "Enrolled" => nice_date(created_at),
      "Last Login" => nice_date(last_sign_in_at), "Gender" => gender, "Age" => age }
  end

  def self.filename utype
    (utype.blank? ? "All" : UserType.where(code: utype).first.description) + "_" +
      ResetDate::display_date_by_loc(Time.now, Geocoder.coordinates("San Francisco, CA"), false).strftime("%Y_%m_%d")
  end

  # set sphinx scopes
   sphinx_scope(:first_name) { 
     {:order => 'first_name, last_name ASC'}
  }  

  sphinx_scope(:by_email) { |email|
    {:conditions => {:email => email}}
  }
end
