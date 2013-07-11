module ListingsHelper

  # format time
  def get_local_time(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y %I:%M%p') rescue nil
  end

  # format short date
  def short_date(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y') rescue nil
  end

  # format short time
  def short_time tm
    tm.utc.getlocal.strftime('%I:%M%p') rescue nil
  end
end
