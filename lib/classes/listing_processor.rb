class ListingProcessor < ListingDataProcessor
  include CalcTotal, SystemMessenger, NameParse, ProcessMethod

  # set active status
  def activate
    if @listing.status != 'sold'
      @listing.id, @listing.status, @listing.start_date = nil, 'active', Time.now 
      @listing.set_end_date
    end
    @listing
  end

  # mark pixi as sold
  def mark_as_sold
    unless @listing.sold?
      @listing.update_attribute(:status, 'sold') if @listing.amt_left == 0
    else
      @listing.errors.add(:base, 'Pixi already marked as sold.')
      false
    end
  end

  # return wanted users 
  def wanted_users pid
    User.where(id: PixiWant.where("pixi_id = ? AND status = ?", pid, 'active').pluck(:user_id)).order("users.first_name")
  end

  # return asked users 
  def asked_users pid
    User.where(id: PixiAsk.where(pixi_id: pid).pluck(:user_id)).order("users.first_name")
  end

  # mark saved pixis if sold or closed
  def sync_saved_pixis
    SavedListing.update_status @listing.pixi_id, @listing.status unless @listing.active?
  end

  # build array of closed statuses
  def closed_arr flg=true
    result = ['closed', 'removed', 'inactive', 'expired'] 
    flg ? (result << 'sold') : result
  end

  # sends email to users who saved the listing when listing is removed
  def send_saved_pixi_removed
    if closed_arr.detect {|closed| @listing.status == closed }
      saved_listings = SavedListing.active_by_pixi(pixi_id) rescue nil
      if saved_listings
        saved_listings.each do |saved_listing|
          if closed_arr.detect {|closed| saved_listing.status == closed }
            UserMailer.delay.send_saved_pixi_removed(saved_listing) unless @listing.buyer_id == saved_listing.user_id
          end
        end
      end
    end
  end

  # toggle invoice status on removing pixi from board
  def set_invoice_status
    if closed_arr(true).detect { |x| x == @listing.status }
      val = @listing.status == 'sold' ? 'closed' : @listing.status
      @listing.invoices.find_each do |inv|
	inv.update_attribute(:status, val) if inv.unpaid? && inv.invoice_details.size == 1 
      end
    end
  end

  # sends notifications after pixi is posted to board
  def async_send_notification 
    if @listing.active?
      ptype = @listing.premium? ? 'app' : 'abp' 
      val = @listing.repost_flg ? 'repost' : 'approve'

      # update points & send message
      PointManager::add_points @listing.user, ptype if @listing.user
      SystemMessenger::send_message @listing.user, @listing, val rescue nil
      UserMailer.delay.send_approval(@listing) unless @listing.skip_approval_email

      # remove temp pixi
      delete_temp_pixi @listing.pixi_id unless @listing.repost_flg
    end
  end

  # set remove item list based on pixi type
  def remove_item_list
    if @listing.job? 
      ['Filled Position', 'Removed Job']
    elsif @listing.event?  
      ['Event Cancelled', 'Event Ended']
    else
      ['Changed Mind', 'Donated Item', 'Gave Away Item', 'Sold Item']
    end
  end

  # reposts existing sold, removed or expired pixi as new
  def repost_pixi
    listing = Listing.new(get_attr(true))
    listing = add_photos false, listing
    listing.generate_token
    listing.status, listing.repost_flg = 'active', true
    listing.save!
  end

  # process pixi repost based on pixi status
  def repost
    if @listing.expired? || @listing.removed?
      @listing.status, @listing.repost_flg, @listing.explanation  = 'active', true, nil
      @listing.save!
      async_send_notification # send notification
    elsif @listing.sold?
      repost_pixi
    else
      false
    end
  end

  def no_invoice_pixis pixi_ids
    Listing.active.where(pixi_id: pixi_ids).includes(:invoices).having("count(invoice_details.id) = 0").delete_if { |x| x.id.nil? }
  end

  def other_pixis pixi_ids
    Listing.active.where("pixi_id IN (?) AND (category_id IN (?) OR price IS NULL)", pixi_ids, Category.where(name: "Jobs").pluck(:id))
  end

  # return all pixis with wants that are more than number_of_days old and either have no invoices, no price, or are jobs
  def invoiceless_pixis number_of_days=2
    pixi_ids = PixiWant.where("created_at < ?", Time.now - number_of_days.days).pluck(:pixi_id)
    (no_invoice_pixis(pixi_ids) + other_pixis(pixi_ids)).uniq
  end

  # returns purchased pixis from buyer
  def purchased usr
    Listing.where("listings.status not in (?)", closed_arr(false)).joins(:invoices)
      .where("invoices.buyer_id = ? AND invoices.status = ?", usr.id, 'paid').uniq
  end

  # returns sold pixis from seller
  def sold_list usr=nil
    result = select_fields('invoices.updated_at').include_list_without_job_type.joins(:invoices)
    if usr
      result.where("invoices.seller_id = ? AND invoices.status = ?", usr.id, 'paid')
    else
      result.where("invoices.seller_id IS NOT NULL AND invoices.status = ?", 'paid')  
    end
  end

  # update active counter for user
  def update_counter_cache
    User.reset_counters(@listing.seller_id, :active_listings)
  end

  def get_by_url url, page=1
    Listing.active.get_by_seller(User.get_by_url(url), 'active').board_fields.set_page page rescue nil
  end

  def get_board_flds
    ProcessMethod::get_board_flds
  end
end

