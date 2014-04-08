require "open-uri"
require 'open_uri_redirections'
class User < ActiveRecord::Base
  include ThinkingSphinx::Scopes, Area, LocationManager
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
    :fb_user, :provider, :uid, :contacts_attributes, :status, :acct_token, :preferences_attributes, :user_type_code

  before_save :ensure_authentication_token unless Rails.env.test?

  # define pixi relationships
  has_many :listings, foreign_key: :seller_id, dependent: :destroy
  has_many :active_listings, foreign_key: :seller_id, class_name: 'Listing', :conditions => "status = 'active' AND end_date >= curdate()"
  has_many :purchased_listings, foreign_key: :buyer_id, class_name: 'Listing', conditions: { :status => 'sold' }
  has_many :temp_listings, foreign_key: :seller_id, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :pixi_likes, dependent: :destroy
  has_many :pixi_wants, dependent: :destroy

  # define site relationships
  has_many :site_users, :dependent => :destroy
  has_many :sites, :through => :site_users

  # define user relationships
  belongs_to :user_type, primary_key: 'code', foreign_key: 'user_type_code'
  has_many :user_interests, :dependent => :destroy
  has_many :interests, :through => :user_interests
  has_many :user_pixi_points, dependent: :destroy

  # define message relationships
  has_many :posts, dependent: :destroy
  has_many :incoming_posts, :foreign_key => "recipient_id", :class_name => "Post", :dependent => :destroy

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
  validates :first_name,  :presence => true,
            :length   => { :maximum => 30 },
 	    :format => { :with => name_regex }  

  validates :last_name,  :presence => true,
            :length   => { :maximum => 30 },
 	    :format => { :with => name_regex }  

  validates :birth_date,  :presence => true  
  validates :gender,  :presence => true
  validate :must_have_picture
  validate :must_have_zip

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
      if home_zip.blank? 
        errors.add(:base, 'Must have a zip')
        false
      else
        # check for valid zip
        if home_zip.to_region 
	  true 
	else
          errors.add(:base, 'Must have a valid zip')
	  false
	end
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

  # used to add pictures for new user
  def with_picture
    self.pictures.build if self.pictures.blank?
    self.preferences.build if self.preferences.blank?
    self
  end

  # check for a picture
  def any_pix?
    pictures.detect { |x| x && !x.photo_file_name.nil? }
  end

  # combine name
  def name
    [first_name, last_name].join " "
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

  # return all new pixis for user
  def new_pixis
    self.temp_listings.where("status NOT IN ('approved', 'pending', 'denied')")
  end

  # return all pending pixis for user
  def pending_pixis
    self.temp_listings.where("status IN ('pending', 'denied')")
  end

  # return all pixis for user
  def sold_pixis
    self.listings.get_by_status('sold')
  end

  # return whether user has any bank accounts
  def has_bank_account?
    bank_accounts.count > 0 rescue nil
  end

  # return whether user has any card accounts
  def has_card_account?
    card_accounts.count > 0 rescue nil
  end

  # return any valid card 
  def get_valid_card
    mo, yr = Date.today.month, Date.today.year
    card_accounts.detect { |x| x.expiration_year > yr || (x.expiration_year == yr && x.expiration_month >= mo) }
  end

  # converts date format
  def self.convert_date(old_dt)
    Date.strptime(old_dt, '%m/%d/%Y') if old_dt    
  end  

  # process facebook user
  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    # load token
    data = access_token.extra.raw_info

    # find or create user
    unless user = User.where(:email => data.email).first
      user = User.new(:first_name => data.first_name, :last_name => data.last_name, 
	      :birth_date => convert_date(data.birthday), :provider => access_token.provider, :uid => access_token.uid, :email => data.email) 
      user.password = user.password_confirmation = Devise.friendly_token[0,20]
      user.fb_user = true
      user.gender = data.gender.capitalize rescue nil
      user.home_zip = LocationManager::get_home_zip(data.location) rescue nil

      #add photo 
      picture_from_url user, access_token
      user.save(:validate => false)
    end
    user
  end

  # add photo from url
  def self.picture_from_url usr, access_token
    pic = usr.pictures.build
    avatar_url = process_uri(access_token.info.image.sub("square","large"))
    pic.photo = URI.parse(avatar_url) 
    pic
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

  def email_required?
    super && provider.blank?
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
    self.contacts.build if self.contacts.blank?
    if contacts[0]
      !contacts[0].address.blank? && !contacts[0].city.blank? && !contacts[0].state.blank? && !contacts[0].zip.blank?
    else
      false
    end
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
    Post.unread_count self rescue 0
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

  # return users by type
  def self.get_by_type val, pg=1
    val.blank? ? all : where(:user_type_code => val)
  end

  # handle https uri requests
  def self.process_uri uri
    unless uri.blank?
      open(uri, :allow_redirections => :safe) do |r|
        r.base_uri.to_s
      end
    end
  end

  # display user type
  def type_descr
    user_type.description rescue nil
  end

  # set json string
  def as_json(options={})
    super(only: [:id, :first_name, :last_name, :email, :birth_date, :gender, :current_sign_in_ip, :fb_user], 
          methods: [:name, :photo, :unpaid_invoice_count, :pixi_count, :unread_count, :birth_dt, :home_zip], 
          include: {active_listings: {}, unpaid_received_invoices: {}, bank_accounts: {}, contacts: {}, card_accounts: {}})
  end

  # set sphinx scopes
   sphinx_scope(:first_name) { 
     {:order => 'first_name, last_name ASC'}
  }  

  sphinx_scope(:by_email) { |email|
    {:conditions => {:email => email}}
  }
end
