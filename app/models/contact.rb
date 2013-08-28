class Contact < ActiveRecord::Base
  attr_accessible :address, :address2, :city, :home_phone, :mobile_phone, :state, :work_phone, :zip, :website, :country, :lng, :lat, :county
   
  belongs_to :contactable, :polymorphic => true, :dependent => :destroy

  name_regex =  /^[A-Z]'?['-., a-zA-Z]+$/i

  validates :city, :presence => true, :format => { :with => name_regex }
  validates :state, :presence => true
  
  geocoded_by :full_address, :latitude  => :lat, :longitude => :lng
  after_validation :geocode  

  def full_address
    [address, city, state, country].compact.join(', ')
  end

  # get by type
  def self.get_by_type val
    where contactable_type: val
  end
end
