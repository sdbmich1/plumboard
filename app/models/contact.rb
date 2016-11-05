class Contact < ActiveRecord::Base
  include AddressManager
  attr_accessible :address, :address2, :city, :home_phone, :mobile_phone, :state, :work_phone, :zip, :website, :country, :lng, :lat, :county
   
  belongs_to :contactable, :polymorphic => true

  name_regex =  /\A[A-Z]'?['-., a-zA-Z]+\z/i

  validates :city, :presence => true, :format => { :with => name_regex }
  validates :state, :presence => true
  validates :zip, allow_blank: true, length: {in: 5..15}
  validates :home_phone, allow_blank: true, length: {in: 10..15}
  validates :mobile_phone, allow_blank: true, length: {in: 10..15}
  validates :work_phone, allow_blank: true, length: {in: 10..15}
  
  geocoded_by :full_address, :latitude  => :lat, :longitude => :lng
  after_validation :geocode,
    :if => lambda{ |obj| obj.address_changed? || obj.zip_changed? }

  # display full address
  def full_address
    addr = AddressManager::full_address self
  end

  # get by type
  def self.get_by_type val
    where contactable_type: val
  end

  # get sites associated with contact location
  def self.get_sites city, state
    uniq.where("city = ? and state = ?", city, state).get_by_type('Site').pluck(:contactable_id)
  end

  # get proximity
  def self.proximity ip, range=25, pos=nil, geoFlg=false, ctype='Site'
    val = geoFlg && pos ? pos : ip
    near(val, range).get_by_type(ctype).map(&:contactable_id).uniq rescue nil
  end

  # set json string
  def as_json(options={})
    super(except: [:contactable_id, :contactable_type, :created_at, :updated_at, :website, :home_phone, :mobile_phone] )
  end
end
