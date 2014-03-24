class UserMailer < ActionMailer::Base
  default from: '"PixiSupport" <support@pixiboard.com>'

  helper :application, :transactions, :listings

  # send receipts to customers
  def send_transaction_receipt transaction
    @transaction = transaction

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{transaction.email}", :subject => "Your Purchase Receipt: #{transaction.confirmation_no} ") 
  end

  # send pixi post request to sellers
  def send_pixipost_request post 
    @post = post

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{post.seller_email}", :subject => "PixiPost Request Submitted") 
  end

  # send pixi post appt to sellers
  def send_pixipost_appt post 
    @post = post

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{post.seller_email}", :subject => "PixiPost Appointment Scheduled") 
  end

  # send inquiry response to user
  def send_inquiry inquiry 
    @inquiry = inquiry

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@inquiry.email}", :subject => "Pixiboard Inquiry: #{@inquiry.contact_type} #{@inquiry.id}")
  end

  # send inquiry response to pxb
  def send_inquiry_notice inquiry 
    @inquiry = inquiry

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "support@pixiboard.com", :subject => "Pixiboard Inquiry: #{@inquiry.contact_type} #{@inquiry.id}")
  end

  # send payment receipts to sellers
  def send_payment_receipt inv, payment
    @payment, @invoice = payment, inv

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@invoice.seller_email}", :subject => "Your Payment Receipt: #{@payment.id} ") 
  end

  # send post notices to members
  def send_notice post
    @post = post

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{post.recipient.email}", :subject => "Pixiboard Post: #{post.pixi_title} ") 
  end

  # send interest notices to members
  def send_interest want
    @want = want
    @listing = @want.listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@listing.seller_email}", :subject => "Pixiboard Post: Someone Wants Your #{@listing.title} ") 
  end

  # send approval notices to members
  def send_approval listing
    @listing = listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{listing.seller_email}", :subject => "Pixi Approved: #{listing.title} ") 
  end

  # send denial notices to members
  def send_denial listing
    @listing = listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{listing.seller_email}", :subject => "Pixi Denied: #{listing.title} ") 
  end

  # send confirm message to new members
  def confirmation_instructions user
    @user = user

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{user.email}", :subject => "Welcome to Pixiboard Community!")
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
