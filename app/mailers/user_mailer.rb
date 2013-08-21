class UserMailer < ActionMailer::Base
  default from: "support@pixiboard.com"

  helper :transactions

  # send receipts to customers
  def send_transaction_receipt transaction
    @transaction = transaction

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{transaction.email}", :subject => "Your Purchase Receipt: #{transaction.confirmation_no} ") 
  end

  # send payment receipts to sellers
  def send_payment_receipt inv, payment
    @payment, @invoice = payment, inv

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@invoice.seller.email}", :subject => "Your Payment Receipt: #{@payment.id} ") 
  end

  # send post notices to members
  def send_notice post
    @post = post

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{post.recipient.email}", :subject => "Pixiboard Post: #{post.pixi_title} ") 
  end

  # send confirm message to new members
  def confirmation_instructions user
    @user = user

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{user.email}", :subject => "Your New Pixiboard Account")
  end

  # send welcome message to new members
  def welcome_email user
    @user = user

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{user.email}", :subject => "Welcome to Pixiboard Community!")
  end

  # set logo image
  def set_logo_image
    img = { :data => File.read("#{Rails.root.to_s + '/app/assets/images/px_word_logo.png'}"),
	    :mime_type => "image/png",
	    :encoding => "base64" }
  end
end
