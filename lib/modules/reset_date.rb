module ResetDate
  
  # used to reset date strings to rails date format
  def self.parse_date(old_dt)
    new_dt = old_dt.split('/') if old_dt
    Date.parse([new_dt[2], new_dt[0], new_dt[1]].join('-')) rescue nil
  end
  
  def self.convert_date(old_dt)
    Date.strptime(old_dt, '%m/%d/%Y') if old_dt    
  end   

  # convert dates to rails format
  def self.reset_dates(val, cType='TempListing')
    if cType == 'TempListing'
      convert_time_fld val, %w(event_start_time event_end_time)
      convert_date_fld val, %w(event_start_date event_end_date)
    else
      convert_time_fld val, %w(preferred_time alt_time appt_time completed_time)
      convert_date_fld val, %w(preferred_date alt_date appt_date completed_date)
    end
    val
  end

  # format display date by location
  def self.display_date_by_loc tm, ll, strFlg=true
    timezone = Timezone::Zone.new :latlon => ll rescue nil
    zone = timezone.blank? ? 'America/Los_Angeles' : timezone.zone  
    if strFlg
      tm.utc.in_time_zone(zone).strftime('%m/%d/%Y %l:%M %p') rescue Time.now.strftime('%m/%d/%Y %l:%M %p')
    else
      tm.utc.in_time_zone(zone) rescue Time.now
    end
  end

  # format display date by zip
  def self.format_date tm, zip
    val = zip ? zip.to_gmt_offset.to_i : 0 rescue 0
    val == 0 ? tm : tm.advance(hours: val)
    tm.strftime('%m/%d/%Y %l:%M %p') rescue Time.now.strftime('%m/%d/%Y %l:%M %p')
  end

  # returns start_date and end_date based on passed date_range
  def self.get_date_range date_range
    case date_range
      when "Last 7 Days"
        [Time.now - 7.days, Time.now]
      when "Last 15 Days"
        [Time.now - 15.days, Time.now]
      when "This Month"
        [Time.now.at_beginning_of_month, Time.now]
      when "Last Month"
        [(Time.now - 1.month).at_beginning_of_month, (Time.now - 1.month).at_end_of_month]
      when "This Quarter"
        [Time.now.beginning_of_quarter, Time.now]
      when "Last Quarter"
        [(Time.now - 90.days).beginning_of_quarter, (Time.now - 90.days).end_of_quarter]
      when "This Year"
        [Time.now.at_beginning_of_year, Time.now]
      else
        [Time.now - 30.days, Time.now]
    end
  end

  # calculate remaining SLGB days
  def self.days_left
    val = ('2015-02-01'.to_date - Date.today).to_i
    val < 10 ? "0#{val}" : val
  end

  def self.convert_time_fld val, arr
    arr.each do |fld|
      val.parse_time_select! fld.to_sym
    end
  end

  def self.convert_date_fld val, arr
    arr.each do |fld|
      val[fld.to_sym] = parse_date(val[fld.to_sym]) if val[fld.to_sym] 
    end
  end
end
