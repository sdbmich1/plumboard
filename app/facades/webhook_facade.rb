class WebhookFacade
  attr_reader :event

  def initialize(event)
    @event = event
  end

  def process
    method_name = 'send_' + @event.type.gsub('.', '_')
    user = User.find_by_email(@event.data.object.email)
    case @event.type
    when 'customer.subscription.created', 'customer.subscription.updated', 'customer.subscription.trial_will_end'
      sub = user.subscriptions.find_by_stripe_id(@event.data.object.id)
      UserMailer.send(method_name.to_sym, user, sub).deliver_later
    when 'charge.dispute.updated'
      evidence = @event.data.object.evidence
      UserMailer.send(method_name.to_sym, user, evidence).deliver_later      
    else
      UserMailer.send(method_name.to_sym, user).deliver_later
    end
  end
end
