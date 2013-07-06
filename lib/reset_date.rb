module ResetDate
  
  # used to reset date strings to rails date format
  def self.parse_date(old_dt)
    new_dt = old_dt.split('/') if old_dt
    Date.parse([new_dt[2], new_dt[0], new_dt[1]].join('-')) if new_dt    
  end
  
  def self.convert_date(old_dt)
    Date.strptime(old_dt, '%m/%d/%Y') if old_dt    
  end   

  def self.reset_dates(val)
    if val[:"event_start_time(5i)"]
      val[:event_start_time] = val[:"event_start_time(5i)"]
      val.delete(:"event_start_time(5i)")
    end

    if val[:"event_end_time(5i)"]
      val[:event_end_time] = val[:"event_end_time(5i)"]
      val.delete(:"event_end_time(5i)")
    end

    # convert dates to rails format
    val[:event_start_date] = parse_date(val[:event_start_date]) if val[:event_start_date] 
    val[:event_end_date] = parse_date(val[:event_end_date]) if val[:event_end_date]
    val
  end
end
