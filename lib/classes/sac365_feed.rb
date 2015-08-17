class Sac365Feed < LoadNewsFeed
  # This class is used for the following feeds:
  # "http://www.sacramento365.com/feeds/event/rss/"
  # "http://www.nowplayingnashville.com/feeds/event/" 
  # Specify the feed using feed_url
  def initialize(feed_url)
    @feed = Feed.find_by_url(feed_url)
    if feed_url == "http://www.sacramento365.com/feeds/event/rss/"
      @user_image = "sac365_logo.png"
      @user_email = "sac365feed@pixiboard.com"
    elsif feed_url == "http://www.nowplayingnashville.com/feeds/event/"
      @user_image = "now_playing_nashville_logo.png"
      @user_email = "nowplayingnashvillefeed@pixiboard.com"
    end
    load!
  end

  # The description is everything that's not in <img> or <dd> tags
  def get_description(n)
    fragment = Nokogiri::HTML.fragment(@description_xpath[n].text)
    fragment.search("//img").remove
    fragment.search(".//dd").remove
    remove_leading_spaces(fragment.text)
  end

  # Use the name of the organization hosting the event,
  # which is usually under the 3rd or 4th <dd> element.
  # If that fails, search for the name of the location, 
  # which is stored in the format LOCATION_NAME - STREET_NAME CITY STATE ZIP.
  # If neither were successful, use the name on the email.
  def get_username(email, item_text)
    event = Nokogiri::HTML(item_text)
    dd_xpath = event.xpath("//dd")
    for i in 2..3
      line = dd_xpath[i].text
      line_contains_addr = line.include?(" CA " || " TN ")
      line_is_url = URI.parse(line).include?("http" || "https") rescue false
      unless (line.blank?) || (line =~ /[0-9]/) || line_contains_addr || line_is_url
        return handle_invalid_chars(dd_xpath[i].text)
      end
    end
    dd_xpath.each do |line|
      if line.include?(" CA " || " TN ")
        return handle_invalid_chars(line.text.split(" - ")[0..-2].join(" - "))
      end
    end
    super(email, item_text)
  end

  # Search each <dd> element for a line that matches the email regex
  def get_email_from_description(description, item_text)
    event = Nokogiri::HTML(item_text)
    dd_xpath = event.xpath("//dd")
    for i in 0..dd_xpath.count-1
      line = dd_xpath[i].text
      return line.downcase if line.match(Devise::email_regexp)
    end
    nil
  end

  # Price is in description under "Admission:"
  def get_price(n)
    event = Nokogiri::HTML(@item_xpath[n].text)
    for i in 0..event.xpath("//dd").count-1
      if event.xpath("//dd")[i].text.include?("Admission")
        price = convert_to_price(event.xpath("//dd")[i].text)
      end
      return price if price && price > 0
    end
    0
  end

  # These feeds leave out the decimal point in the price (for example, $1950 instead of $19.50).
  # When a price of at least $1,000 is displayed, there is a comma,
  # so divide by 100 if the price is at least $1,000 and there is no comma.
  def convert_to_price(string)
    price = super(string)
    price >= 1000 && !string.include?(",") ? price / 100.0 : price
  end

  # This feed stores dates and times separately,
  # so this method calls get_event_dates on one section and get_event_times on another.
  # If start_date is not the same day as end_date,
  # the days of the event and the start and end times
  # are listed under the "Start Time(s)" section.
  def get_start_and_end_dates(n)
    event = Nokogiri::HTML(@item_xpath[n].text)
    start_date, end_date = get_event_dates(event.xpath("//dd")[1].text)
    for i in 0..event.xpath("//dd").count-1
      if event.xpath("//dd")[i].text.include?("Start Time(s):")
        # Set default end time before calling get_event_times
        # (in case it does not assign successfully)
        return get_event_times(event.xpath("//dd")[i].text, start_date,
          set_default_end_time(end_date))
      end
    end
  end
end