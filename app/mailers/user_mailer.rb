class UserMailer < ActionMailer::Base
  include UserMailerHelper
  default from: '"PixiSupport" <support@pixiboard.com>'

  helper :application, :transactions, :listings, :invoices, :pending_listings, :user_mailer

  # send receipts to customers
  def send_transaction_receipt transaction
    @transaction = transaction
    @invoice = transaction.get_invoice

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
    mail(:to => "#{post.seller_email}", :subject => env_check + ' ' + "PixiPost Request Submitted") 
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
    mail(:to => "#{@inquiry.email}", :subject => "Pixiboard Inquiry Received!")
  end

  # send inquiry response to pxb
  def send_inquiry_notice inquiry 
    @inquiry = inquiry

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "support@pixiboard.com", :subject => env_check + ' ' + "Pixiboard Inquiry: #{@inquiry.subject}")
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
    mail(:to => "#{post.recipient_email}", :subject => "Pixiboard Post: #{post.pixi_title} ") 
  end

  # send interest notices to members
  def send_interest want
    @want = want
    @listing = @want.listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@listing.seller_email}", :subject => env_check + ' ' + "Pixiboard Post: Someone Wants Your #{@listing.title} ") 
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

  # send submit response to pxb
  def send_submit_notice listing 
    @listing = listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "support@pixiboard.com", :subject => env_check + ' ' + "Pixi Submitted: #{@listing.nice_title}")
  end

  # set logo image
  def set_logo_image
    img = { :data => File.read("#{Rails.root.to_s + '/app/assets/images/px_word_logo.png'}"), :mime_type => "image/png", :encoding => "base64" }
  end

  # send saved pixi notice
  def send_save_pixi saved_listing
    @listing = saved_listing.listing
    @saved_listing = saved_listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{saved_listing.user.email}", :subject => "Your Pixi is Saved!")
  end

  #send pixi_post submit notice internally
  def send_pixipost_request_internal post
    @post = post

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "support@pixiboard.com", :subject => env_check + ' ' + "PixiPost Request Submitted")
  end

  #send notice that saved pixi is removed
  def send_saved_pixi_removed saved_listing
    @listing = saved_listing.listing
    @saved_listing = saved_listing
    @status = @listing.status

    #set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    #set message details
    mail(:to => "#{saved_listing.user.email}", :subject => "Saved Pixi is Sold/Removed")
  end
end
