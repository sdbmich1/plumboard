require "open-uri"
class User < ActiveRecord::Base
  include ThinkingSphinx::Scopes
  rolify
  acts_as_reader

  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
  	 :token_authenticatable, :confirmable,
  	 :lockable, :timeoutable, :omniauthable, :omniauth_providers => [:facebook]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :birth_date, :gender, :pictures_attributes,
    :fb_user, :provider, :uid, :contacts_attributes, :status

  # define relationships
  has_many :listings, foreign_key: :seller_id
  has_many :active_listings, foreign_key: :seller_id, class_name: 'Listing', conditions: { :status => 'active' }
  has_many :temp_listings, foreign_key: :seller_id, dependent: :destroy

  has_many :site_users, :dependent => :destroy
  has_many :sites, :through => :site_users

  has_many :user_interests, :dependent => :destroy
  has_many :interests, :through => :user_interests

  has_many :posts, dependent: :destroy
  has_many :incoming_posts, :foreign_key => "recipient_id", :class_name => "Post", :dependent => :destroy

  has_many :invoices, foreign_key: :seller_id
  has_many :unpaid_invoices, foreign_key: :seller_id, class_name: 'Invoice', conditions: { :status => 'unpaid' }
  has_many :paid_invoices, foreign_key: :seller_id, class_name: 'Invoice', conditions: { :status => 'paid' }
  has_many :received_invoices, :foreign_key => "buyer_id", :class_name => "Invoice"

  has_many :bank_accounts, dependent: :destroy
  has_many :transactions, dependent: :destroy

  has_many :user_pixi_points, dependent: :destroy

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true, :reject_if => :all_blank

  has_many :contacts, :as => :contactable, :dependent => :destroy
  accepts_nested_attributes_for :contacts, :allow_destroy => true, :reject_if => :all_blank

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

  # validate picture exists
  def must_have_picture
    if !any_pix?
      errors.add(:base, 'Must have a picture')
      false
    else
      true
    end
  end

  # used to add pictures for new user
  def with_picture
    self.pictures.build if self.pictures.blank?
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

  # return all pixis for user
  def pixis
    self.listings.active
  end

  # return whether user has pixis
  def has_pixis?
    pixis.size > 0
  end

  # return all new pixis for user
  def new_pixis
    self.temp_listings.where("status NOT IN ('approved')")
  end

  # return all pixis for user
  def sold_pixis
    self.listings.get_by_status('sold')
  end

  # return whether user has any bank accounts
  def has_bank_account?
    bank_accounts.size > 0 rescue nil
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
	      :birth_date => convert_date(data.birthday), :provider => access_token.provider, :uid => access_token.uid,
	      :gender => data.gender.capitalize, :email => data.email) 
      user.password = user.password_confirmation = Devise.friendly_token[0,20]
      user.fb_user = true

      #add photo 
      picture_from_url user, access_token
      user.save(:validate => false)
    end
    user
  end

  # add photo from url
  def self.picture_from_url usr, access_token
    pic = usr.pictures.build
    pic.photo = URI.parse(access_token.info.image.sub("square","large")) rescue nil
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

  # set account to inctive status
  def deactivate
    self.status = 'inactive'
    self
  end

  # display image with name for autocomplete
  def pic_with_name
    pic = self.pictures[0].photo(:tiny) rescue nil
    pic ? "<img src='#{pic}' class='inv-pic' /> #{self.name}" : nil
  end

  # set sphinx scopes
  sphinx_scope(:by_email) { |email|
    {:conditions => {:email => email}}
  }

end
