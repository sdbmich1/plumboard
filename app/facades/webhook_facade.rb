class WebhookFacade
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def process
    method_name = 'send_' + @event.type.gsub('.', '_')
    user = User.find_by_email(@event.data.object.email)
    UserMailer.send(method_name.to_sym, user).deliver_later
  end
end
