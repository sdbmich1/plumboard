class UserMailer < ActionMailer::Base
  default from: "support@pixiboard.com"

  helper :transactions

  # send receipts to customers
  def send_transaction_receipt transaction
    @transaction = transaction

    # set logo
    attachments.inline['px_word_logo.png'] = set_logo_image

    # set message details
    mail(:to => "#{transaction.email}", :subject => "Your Purchase Receipt: #{transaction.confirmation_no} ") 
  end

  # send post notices to members
  def send_notice post
    @post = post

    # set logo
    # attachments.inline['px_word_logo.png'] = File.read("#{Rails.root.to_s + '/app/assets/images/px_word_logo.png'}")
    attachments.inline['px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","px_word_logo.png") )

    # set message details
    mail(:to => "#{post.recipient.email}", :subject => "Pixiboard Post: #{post.pixi_title} ") 
  end

  # set logo image
  def set_logo_image
    img = { :data => File.read("#{Rails.root.to_s + '/app/assets/images/px_word_logo.png'}"),
	    :mime_type => "image/png",
	    :encoding => "base64" }
  end
end
