class TransactionDetail < ActiveRecord::Base
  attr_accessible :item_name, :price, :quantity, :transaction_id

  # Prevent ActiveRecord from raising an error when overriding transaction method
  def self.dangerous_attribute_method?(name)
    super && name != :transaction
  end

  belongs_to :transaction

  validates :item_name, :presence => true
  validates :quantity, :presence => true, :numericality => true
  validates :price, :presence => true, :numericality => true
end
