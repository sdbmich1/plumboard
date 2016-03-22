class FulfillmentType < ActiveRecord::Base
  attr_accessible :code, :description, :status, :hide

  has_many :listings, primary_key: 'code', foreign_key: 'fulfillment_type_code'
  has_many :temp_listings, primary_key: 'code', foreign_key: 'fulfillment_type_code'
  has_many :invoice_details, primary_key: 'code', foreign_key: 'fulfillment_type_code'
  has_many :preferences, primary_key: 'code', foreign_key: 'fulfillment_type_code'
  
  validates_presence_of :description, :code, :status, :hide

  default_scope { order "description ASC" }

  # return active types
  def self.active
    where(:status => 'active')
  end

  # return all unhidden types
  def self.unhidden
    active.where(:hide => 'no')
  end

  # titleize descr
  def nice_descr
    description.titleize rescue nil
  end

  def self.buyer_options listing
    if listing.fulfillment_type_code.nil?
      where(code: 'P')
    elsif listing.fulfillment_type_code == 'A'
      unhidden.where("code != 'A'")
    elsif listing.fulfillment_type_code == 'PS'
      where(code: ['P', 'SHP'])
    else
      unhidden.where(code: listing.fulfillment_type_code)
    end
  end

  def self.ship_codes
    %w(SHP PS SD)
  end
end
