module ListingsHelper

  # format time
  def get_local_time(tm)
    tm.utc.getlocal.strftime('%m/%d/%Y %I:%M%p') rescue nil
  end
end
