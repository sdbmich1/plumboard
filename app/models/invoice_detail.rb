class InvoiceDetail < ActiveRecord::Base
  attr_accessible :invoice_id, :pixi_id, :price, :quantity, :subtotal

  belongs_to :invoice
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"

  validates_presence_of :pixi_id
  validates :price, presence: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
    		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_PIXI_AMT.to_f }
  validates :quantity, presence: true, :numericality => { greater_than: 0, less_than_or_equal_to: MAX_INV_QTY.to_i }    
  validates :subtotal, presence: true, :numericality => { greater_than: 0 }

  def pixi_title
    listing.title rescue nil
  end
end
