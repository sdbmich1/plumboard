class PixiPayment < ActiveRecord::Base
  attr_accessible :amount, :buyer_id, :invoice_id, :pixi_fee, :pixi_id, :seller_id, :token, :transaction_id
end
