class User < ActiveRecord::Base
  rolify

  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
  	 :token_authenticatable, :confirmable,
  	 :lockable, :timeoutable and :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :birth_date, :gender, :pictures_attributes

  # define relationships
  has_many :contacts, :as => :contactable, :dependent => :destroy
  has_many :listings, foreign_key: :seller_id
  has_many :temp_listings, foreign_key: :seller_id, dependent: :destroy

  has_many :site_users, :dependent => :destroy
  has_many :sites, :through => :site_users

  has_many :user_interests, :dependent => :destroy
  has_many :interests, :through => :user_interests

  has_many :posts, dependent: :destroy
  has_many :incoming_posts, :foreign_key => "recipient_id", :class_name => "Post", :dependent => :destroy

  has_many :transactions, dependent: :destroy

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true, :reject_if => :all_blank

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
  validates :password, presence: true
  validates :password_confirmation, presence: true
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

  def with_picture
    self.pictures.build
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
    self.listings | self.temp_listings
  end
end
