class MessageType < ActiveRecord::Base
  attr_accessible :code, :description, :recipient, :status

  has_many :messages, primary_key: 'code', foreign_key: 'message_type_code'

  def self.get_codes
    where(status: 'active')
  end
end
