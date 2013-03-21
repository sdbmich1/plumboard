class UserMailer < ActionMailer::Base
  default from: "support@pixiboard.com"

  helper :transactions

  # send receipts to customers
  def send_transaction_receipt transaction
    @transaction = transaction

    # set message details
    mail(:to => "#{transaction.email}", :subject => "Your Purchase Receipt: #{transaction.confirmation_no} ") 
  end

end
