class NotificationSender
  @queue = :notifications

  def self.perform(message, devices, options)
    Pushwoosh.notify_devices(message, devices, options)
  end
end
