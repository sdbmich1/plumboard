class PromoCode < ActiveRecord::Base
  attr_accessible :amountOff, :code, :currency, :description, :end_date, :end_time, :max_redemptions, :percentOff, :promo_name, 
  	:start_date, :start_time, :status, :promo_type, :site_id

  belongs_to :site
  
  validates :code, presence: true
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
    result = active.find_by_code cd
    get_valid_code result, dt if result
  end
end
