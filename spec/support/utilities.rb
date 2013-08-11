  # Returns the full title on a per-page basis.
  def full_title page_title
    base_title = "Pixiboard"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

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

  def (ActionDispatch::Integration::Session).fixture_path
    RSpec.configuration.fixture_path
  end
