class UserMailer < ActionMailer::Base
  include UserMailerHelper
  default from: '"PixiSupport" <support@pixiboard.com>'

  helper :application, :transactions, :listings, :invoices, :pending_listings, :user_mailer

  # send receipts to customers
  def send_transaction_receipt transaction
    @invoice = transaction.get_invoice
    @transaction = transaction

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{transaction.email}", :subject => env_check + ' ' + "Your Purchase Receipt: #{transaction.confirmation_no} ") 
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
    mail(:to => "#{post.seller_email}", :subject => env_check + ' ' + "PixiPost Appointment Scheduled") 
  end

  # send inquiry response to user
  def send_inquiry inquiry 
    @inquiry = inquiry

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@inquiry.email}", :subject => env_check + ' ' + "Pixiboard Inquiry Received!")
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
    mail(:to => "#{@invoice.seller_email}", :subject => env_check + ' ' + "Your Payment Receipt: #{@payment.id} ") 
  end

  # send post notices to members
  def send_notice post
    @post = post

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{post.recipient_email}", :subject => env_check + ' ' + "Pixiboard Post: #{post.pixi_title} ") 
  end

  # send interest notices to members
  def send_interest want
    @want, @listing = want, want.listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@listing.seller_email}", :subject => env_check + ' ' + "Pixiboard Post: Someone Wants Your #{@listing.title} ") 
  end

  #send ask 
  def ask_question ask
    @ask = ask
    @listing = @ask.listing
    #set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    #set message details
    mail(:to => "#{@listing.seller_email}", :subject => env_check + ' ' + "Pixiboard Ask: Someone Has a Question About Your #{@listing.title} ") 

    #set message details
  end
  # send approval notices to members
  def send_approval listing
    @listing = listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{listing.seller_email}", :subject => env_check + ' ' + "Pixi #{approve_type(listing)}: #{listing.title} ") 
  end

  # send denial notices to members
  def send_denial listing
    @listing = listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{listing.seller_email}", :subject => env_check + ' ' + "Pixi Denied: #{listing.title} ") 
  end

  # send confirm message to new members
  def confirmation_instructions user
    @user = user

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{user.email}", :subject => env_check + ' ' + "Welcome to Pixiboard Community!")
  end

  # send welcome message to new members
  def welcome_email user
    @user = user

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{user.email}", :subject => env_check + ' ' + "Welcome to Pixiboard Community!")
  end

  # send submit response to pxb
  def send_submit_notice listing 
    @listing = listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "support@pixiboard.com", :subject => env_check + ' ' + "Pixi Submitted: #{@listing.nice_title(false)}")
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

  #send notice that pixi is expiring soon
  def send_expiring_pixi_notice number_of_days, user
    @number_of_days = number_of_days
    @user = user
    #set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )
    #set message details
    mail(:to => "#{user.email}", :subject => "Your Pixis are Expiring Soon!")
  end

  # send notice for each pixi that has a want at least number_of_days old
  def send_invoiceless_pixi_notice listing
    @listing = listing

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@listing.seller_email}", :subject => env_check + ' ' + "Reminder: Someone Wants Your #{@listing.title} ")
  end

  # send notice for an unpaid invoice at least number_of_days old
  def send_unpaid_old_invoice_notice invoice
    @invoice = invoice

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@invoice.buyer_email}", :subject => env_check + ' ' + "Reminder: Pixiboard Post: #{@invoice.pixi_title}")
  end

  # send notice for declined invoice
  def send_decline_notice invoice, message
    @invoice = invoice
    @message = message

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@invoice.seller_email}", :subject => env_check + ' ' + "Invoice Declined")
  end

  # send notice for invoice
  def send_invoice_notice invoice
    @invoice = invoice
    @title = invoice.listings.count > 1 ? "multiple pixis" : invoice.pixi_title

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{@invoice.buyer_email}", :subject => env_check + ' ' + "PixiPay Invoice ##{@invoice.id} from #{@invoice.seller_name}")
  end

  # send charge failed notice
  def send_charge_failed user
    @user = user

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{user.email}", :subject => env_check + " Charge Failed")
  end

  # send charge dispute notice
  def send_charge_dispute_created user
    @user = user

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => ["#{user.email}", "support@pixiboard.com"], :subject => env_check + " Charge Disputed")
  end

  # send charge dispute update
  def send_charge_dispute_updated user, evidence
    @user, @evidence = user, evidence

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => ["#{user.email}", "support@pixiboard.com"], :subject => env_check + " Charge Disputed – Update")
  end

  # send charge dispute closed notice
  def send_charge_dispute_closed user
    @user = user

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => ["#{user.email}", "support@pixiboard.com"], :subject => env_check + " Charge Dispute Closed")
  end

  # send subscription notice
  def send_customer_subscription_created user, sub
    @user, @plan = user, sub.plan

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{user.email}", :subject => env_check + " First Payment Received – Thank You")
  end

  # send subscription trial notice
  def send_customer_subscription_trial_will_end user, sub
    @user, @sub, @plan = user, sub, sub.plan

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{user.email}", :subject => env_check + " Your Subscription Trial Will End Soon")
  end

  # send subscription charge notice
  def send_customer_subscription_updated user, sub
    @user, @plan = user, sub.plan

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{user.email}", :subject =>  env_check + " Payment Received – Thank You")
  end

  # send subscription cancellation notice
  def send_customer_subscription_deleted user
    @user = user

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => ["#{user.email}", "support@pixiboard.com"], :subject => env_check + " Your Subscription Has Been Cancelled")
  end

  # send Stripe account update notice
  def send_customer_updated user
    @user = user

    # set logo
    attachments.inline['rsz_px_word_logo.png'] = File.read( Rails.root.join("app/assets/images/","rsz_px_word_logo.png") )

    # set message details
    mail(:to => "#{user.email}", :subject => env_check + " Your Payment Information Has Been Updated")
  end
end
