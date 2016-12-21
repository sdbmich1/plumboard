class PromoCode < ActiveRecord::Base
  include ThinkingSphinx::Scopes
  attr_accessible :amountOff, :code, :currency, :description, :end_date, :end_time, :max_redemptions, :percentOff, :promo_name, 
  	:start_date, :start_time, :status, :promo_type, :site_id, :owner_id, :pictures_attributes, :category_id, :subcategory_id

  belongs_to :site
  belongs_to :category
  belongs_to :user, foreign_key: :owner_id
  has_many :promo_code_users, dependent: :destroy

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true
  
  # validates :code, presence: true
  validates :status, presence: true
  validates :promo_name, presence: true
  validates :amountOff, presence: true, if: "percentOff.blank?"
  validates :percentOff, presence: true, if: "amountOff.blank?"
  validates :start_date, presence: true, unless: "end_date.blank?"
  validates_date :end_date, presence: true, unless: "start_date.blank?", :on_or_after => :start_date
  validates :start_time, presence: true, unless: "end_time.blank?"
  validates :end_time, presence: true, unless: "start_time.blank?"
  with_options :if => :same_day? do |admin|
    admin.validates_datetime :end_time, :after => :start_time, unless: "end_time.blank?"
  end
  
  # get active codes
  def self.active
    where(:status => 'active') 
  end

  # get code that has not expired
  def self.get_valid_code result, dt
    if (result.end_date.blank? && result.start_date.blank?) || (result.start_date..result.end_date).include?(dt)
      result
    else
      nil
    end
  end

  # check if start and end dates are same
  def same_day?
    start_date == end_date
  end

  # check if start time exists
  def has_start_time?
    !start_time.blank?
  end

  # find valid code based on given code and date
  def self.get_code cd, dt
    result = active.find_by code: cd
    get_valid_code result, dt if result
  end
 
  def self.get_local_promos zip, miles=1
    active.where(owner_id: User.get_nearest_stores(zip, miles) )
  end
 
  def self.get_user_promos uid, aflg=false
    if aflg
      User.joins(:promo_codes).include_list.where('promo_codes.status = ?', 'active').uniq.reorder('first_name ASC')  
    else
      active.where(owner_id: uid)
    end
  end

  # seller pic
  def seller_photo
    user.photo 0, 'small' rescue nil
  end

  # get seller name for a listing
  def seller_name
    user.business_name rescue nil
  end

  # set json string
  def as_json(options={})
    output = super(except: [:created_at, :updated_at], methods: [:seller_name, :seller_photo],
      include: {user: { only: [:url], methods: [:rating, :pixi_count] }})
    output['pictures'] = [{ 'photo_url' => self.pictures.first.photo.url(:large) }] if self.pictures[0]
    output
  end

  # set sphinx scopes
   sphinx_scope(:promo_name) { 
     {:order => 'promo_name ASC'}
  }  

  sphinx_scope(:by_description) { |description|
    {:conditions => {:description => description}}
  }
end
