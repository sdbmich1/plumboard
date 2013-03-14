class TransactionDetail < ActiveRecord::Base
  attr_accessible :item_name, :price, :quantity, :transaction_id

  belongs_to :transaction

  validates :transaction_id, :presence => true
  validates :item_name, :presence => true
  validates :quantity, :presence => true, :numericality => true
  validates :price, :presence => true, :numericality => true
end
