# used to process Stripe payments
module StripePayment

  # charge card
  def self.charge_card token, amt, descr, txn
    # set instance var
    @txn = txn

    # charge card
    result = Stripe::Charge.create(:amount => (amt * 100).to_i, :currency => "usd", :card => token, :description => descr) 

    # rescue errors
    rescue Stripe::CardError => e
      process_error e
    rescue Stripe::AuthenticationError => e
      process_error e
    rescue Stripe::InvalidRequestError => e
      process_error e
    rescue Stripe::APIConnectionError => e
      process_error e
    rescue Stripe::StripeError => e
      ExceptionNotifier::Notifier.exception_notification('StripeError', e).deliver if Rails.env.production?
      process_error e
    rescue => e
      process_error e
  end

  # process result data
  def self.process_result result, txn 
    txn.confirmation_no, txn.payment_type, txn.credit_card_no = result.id, result.card[:type], result.card[:last4]
    txn
  end

  # process credit card messages
  def self.process_error e
    @txn.errors.add :base, "There was a problem with your credit card. #{e.message}"    
  end
end
