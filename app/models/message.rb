class Message < ActiveRecord::Base
  attr_accessible :user_id, :device_id, :message_type_code, :content,
    :priority, :reg_id, :collapse_key

  belongs_to :user
  belongs_to :device
  belongs_to :message_type, primary_key: 'code', foreign_key: 'message_type_code'

  serialize :reg_id

  def add_message(msg)
    $redis.lpush(msg[:message_type], msg)
  end

  def self.send_message(key)
    $redis.rpop(key)
  end
end
