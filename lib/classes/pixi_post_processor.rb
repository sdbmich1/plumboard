class PixiPostProcessor
  include AddressManager, ProcessMethod, PointManager, ResetDate

  def initialize post
    @post = post
  end

  # load new pixi post with pre-populated fields
  def load_new usr, zip
    if usr.has_address? && zip == usr.contacts[0].zip
      @post = AddressManager::synch_address @post, usr.contacts[0], false
    else
      loc = PixiPostZip.active.find_by_zip(zip.to_i) rescue nil
      @post.city, @post.state = loc.city, loc.state unless loc.blank?
      @post.mobile_phone, @post.home_phone = usr.contacts[0].mobile_phone, usr.contacts[0].home_phone unless usr.contacts[0].blank?
      @post.zip = zip
    end
    @post
  end

  # display full address
  def full_address
    addr = AddressManager::full_address @post
  end

  def any_pid? pid
    !pid.blank? && !(pid == 0)
  end

  # retrives the data for pixter_report
  def pixter_report start_date, end_date, pid
    !any_pid?(pid) ? PixiPost.completed_posts(start_date, end_date) : PixiPost.completed_posts(start_date, end_date).where(pixan_id: pid)
  end

  # cancels existing post and create new post based on original post
  def reschedule pid
    if old_post = PixiPost.where(id: pid).first

      # remove protected attributes
      arr = %w(id pixan_id appt_date appt_time preferred_date preferred_time alt_date alt_time comments pixi_id created_at updated_at)
      attr = ProcessMethod::get_attr old_post, arr
       
      # remove old post
      old_post.destroy

      # load attributes to new record
      PixiPost.new(attr)
    else
      @post
    end
  end

  # load csv hash
  def csv_data
    { "Post Date" => @post.completed_date, "Item Title" => @post.item_title, "Customer" => @post.seller_name, "Pixter" => @post.pixter_name,
      "Sale Date" => get_val('sale_date'), "List Value" => @post.listing_value,
      "Sale Amount" => get_val('sale_value'), "Pixter Revenue" => get_val('revenue') }
  end

  def get_val fld
    @post.any_sold? ? @post.send(fld) : 'Not sold yet'
  end

  def get_revenue
    @post.sale_value * PXB_TXN_PERCENT * PIXTER_PERCENT rescue 0.0
  end

  def get_item_title val=nil
    @post.pixi_post_details.find_each do |det|
      val = det.listing.title; break
    end
    val
  end

  # returns item's listing value
  def get_post_value 
    val = 0.0
    @post.pixi_post_details.find_each do |det|
      val += det.listing.price rescue 0
    end
    val
  end

  # returns item's sale value
  def get_sale_value 
    val = 0.0
    @post.pixi_post_details.find_each do |det|
      val += det.listing.invoices.where(status: 'paid').sum("invoice_details.subtotal")
    end
    val
  end

  # get sale date
  def get_sale_date
    @post.pixi_post_details.find_each do |det|
      return det.listing.invoices.where(status: 'paid').first.created_at rescue nil
    end
  end

  # send receipt upon request
  def process_request
    PointManager::add_points @post.user, 'ppx' 
    AddressManager::set_user_address @post.user, @post
    UserMailer.delay.send_pixipost_request(@post) if @post.status == 'active'
    UserMailer.delay.send_pixipost_request_internal(@post) if @post.status == 'active'
  end

  # send appointment notice
  def send_appt_notice 
    UserMailer.delay.send_pixipost_appt(@post) if @post.has_appt? && !@post.is_completed?
  end

  # add new post
  def add_post usr
    ProcessMethod::set_guest_user @post, usr, 'inactive'
  end

  # format date based on location
  def format_date dt, dFlg=true
    ll = LocationManager::get_lat_lng_by_loc(full_address)
    ResetDate::display_date_by_loc dt, ll, dFlg rescue Time.now.strftime('%m/%d/%Y %l:%M %p')
  end

  def set_tokens pixi_ids
    pixi_ids.each do |pixi|
      pid = Listing.find_by_pixi_id(pixi) rescue nil
      @post.pixi_post_details.build.pixi_id = pid unless pid.blank?
    end
  end

  # load assn details
  def load_details
    PixiPost.find_each do |post|
      post.pixi_post_details.create pixi_id: post.pixi_id
    end
  end

  def filename
    'Pixter_Report_' + ResetDate::display_date_by_loc(Time.now, Geocoder.coordinates("San Francisco, CA"), false).strftime("%Y_%m_%d")
  end
end

