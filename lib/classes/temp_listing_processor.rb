class TempListingProcessor < ListingDataProcessor
  include CalcTotal, SystemMessenger, NameParse

  # set fields upon creation
  def set_flds
    NameParse::encode_string @listing.title
    NameParse::encode_string @listing.description

    # set as new if empty
    @listing.status = 'new' if @listing.status.blank?
    @listing.generate_token if @listing.pixi_id.blank?
    @listing.alias_name = rand(36**TempListing::ALIAS_LENGTH).to_s(36) if @listing.alias?
    @listing.set_end_date
    @listing
  end

  # add listing to board if approved
  def post_to_board
    if @listing.status == 'approved'
      @listing.dup_pixi true
    else
      @listing.errors.add :base, "Pixi must be approved prior to posting to board."
      false
    end
  end
  handle_asynchronously :post_to_board

  # add listing to board and process transaction
  def async_send_notification 
    case @listing.status
      when 'pending'
        UserMailer.delay.send_submit_notice(@listing)
      when 'approved'
        post_to_board
        @listing.transaction.process_transaction unless @listing.transaction.approved? rescue nil
      when 'denied'
        UserMailer.delay.send_denial(@listing)
        SystemMessenger::send_message @listing.user, @listing, 'deny'
    end
  end

  # submit order request for review
  def submit_order val
    if !val.blank? || @listing.free?
      @listing.transaction_id = val if val
      @listing.status = 'pending' 
      @listing.save!
    else
      @listing.errors.add :base, "Pixi must have transaction to submit an order."
      false
    end
  end

  # check if pixi is free
  def free?
    CalcTotal::get_price(@listing.premium?) == 0.00 rescue true
  end

  # edit order fields to process order
  def edit_flds usr, val, reason=''
    @listing.status, @listing.edited_by, @listing.edited_dt, @listing.explanation = val, usr.name, Time.now, reason
    @listing.save!
  end

  # add new listing
  def add_listing usr
    ProcessMethod::set_guest_user @listing, usr, 'new'
  end
end
