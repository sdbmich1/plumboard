class InvoiceDetail < ActiveRecord::Base
  attr_accessor :amt_left
  attr_accessible :invoice_id, :pixi_id, :price, :quantity, :subtotal, :amt_left, :fulfillment_type_code

  belongs_to :invoice, counter_cache: true
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"
  belongs_to :fulfillment_type, primary_key: 'code', foreign_key: 'fulfillment_type_code'

  validates_presence_of :pixi_id
  validates :price, presence: true, format: { with: /\A\d+??(?:\.\d{0,2})?\z/ }, 
    		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }
  validates :quantity, presence: true, :numericality => { greater_than: 0, less_than_or_equal_to: MAX_INV_QTY.to_i }    
  validates :subtotal, presence: true, format: { with: /\A\d+??(?:\.\d{0,2})?\z/ }, 
                numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f } 

  def pixi_title
    listing.title rescue nil
  end
end
