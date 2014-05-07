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
      val.parse_time_select! :event_start_time
      val.parse_time_select! :event_end_time 
      val[:event_start_date] = parse_date(val[:event_start_date]) if val[:event_start_date] 
      val[:event_end_date] = parse_date(val[:event_end_date]) if val[:event_end_date]
    else
      val.parse_time_select! :preferred_time
      val.parse_time_select! :alt_time 
      val.parse_time_select! :appt_time 
      val.parse_time_select! :completed_time 
      val[:preferred_date] = parse_date(val[:preferred_date]) if val[:preferred_date] 
      val[:alt_date] = parse_date(val[:alt_date]) if val[:alt_date]
      val[:appt_date] = parse_date(val[:appt_date]) if val[:appt_date]
      val[:completed_date] = parse_date(val[:completed_date]) if val[:completed_date]
    end
    val
  end

  # format display date by location
  def self.display_date_by_loc tm, ll
    timezone = Timezone::Zone.new :latlon => ll rescue nil
    unless timezone.blank?
      zone = timezone.zone
      tm.utc.in_time_zone(zone).strftime('%m/%d/%Y %l:%M %p')
    else
      tm.utc.strftime('%m/%d/%Y %l:%M %p')
    end
  end

  # format display date by zip
  def self.format_date tm, zip
    val = zip ? zip.to_gmt_offset.to_i : 0 rescue 0
    val == 0 ? tm : tm.advance(hours: val)
    tm.strftime('%m/%d/%Y %l:%M %p') rescue Time.now.strftime('%m/%d/%Y %l:%M %p')
  end
end
