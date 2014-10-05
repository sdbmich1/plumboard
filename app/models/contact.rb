class Contact < ActiveRecord::Base
  include AddressManager
  attr_accessible :address, :address2, :city, :home_phone, :mobile_phone, :state, :work_phone, :zip, :website, :country, :lng, :lat, :county
   
  belongs_to :contactable, :polymorphic => true, :dependent => :destroy

  name_regex =  /^[A-Z]'?['-., a-zA-Z]+$/i

  validates :city, :presence => true, :format => { :with => name_regex }
  validates :state, :presence => true
  validates :zip, allow_blank: true, length: {in: 5..15}
  validates :home_phone, allow_blank: true, length: {in: 10..15}
  validates :mobile_phone, allow_blank: true, length: {in: 10..15}
  validates :work_phone, allow_blank: true, length: {in: 10..15}
  
  geocoded_by :full_address, :latitude  => :lat, :longitude => :lng
  after_validation :geocode  

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
    stmt = "city = ? and state = ?"
    where(stmt, city, state).get_by_type('Site').map(&:contactable_id).uniq
  end

  # get proximity
  def self.proximity ip, range=25, pos=nil, geoFlg=false
    val = geoFlg && pos ? pos : ip
    near(val, range).get_by_type('Site').map(&:contactable_id).uniq
  end
end
