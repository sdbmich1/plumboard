class Preference < ActiveRecord::Base
  attr_accessible :email_msg_flg, :mobile_msg_flg, :user_id, :zip, :ship_amt,
    :sales_tax, :buy_now_flg, :fulfillment_type_code

  belongs_to :user
  belongs_to :fulfillment_type, primary_key: 'code', foreign_key: 'fulfillment_type_code'

  validates :zip, allow_blank: true, length: {is: 5}
  validates :sales_tax, allow_blank: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
    		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_SALES_TAX.to_i }
  validates :ship_amt, allow_blank: true, format: { with: /^\d+??(?:\.\d{0,2})?$/ }, 
    		numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: MAX_SHIP_AMT.to_i }
end
