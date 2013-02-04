class TransactionDetail < ActiveRecord::Base
  attr_accessible :item_name, :price, :quantity, :transaction_id

  belongs_to :transaction

  validates :item_name, :presence => true
  validates :quantity, :presence => true
  validates :price, :presence => true
end
