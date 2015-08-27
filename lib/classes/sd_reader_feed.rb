class SDReaderFeed < LoadNewsFeed
  def initialize
    @feed = Feed.find_by_url("http://www.sandiegoreader.com/rss/events/")
    @category = Category.find_by_name("Events")
    @user_image = "san_diego_reader_logo.png"
    @user_email = "sdreaderfeed@pixiboard.com"
    load!
  end

  # Format is DATE: EVENT_TITLE, so this method returns everything after the first colon
  def get_title(n)
    super(n).split(":")[1..-1].join(":")[1..-1]    # last [1..-1] removes leading space
  end

  # Description is under "Description:" section
  def get_description(n)
    description = super(n)
    description.include?("Description:") ? description.split("Description:")[1] : nil
  end

  # Price is in description under "Cost:" (before "Age limit:")
  def get_price(n)
    convert_to_price(@description_xpath[n].text.split("Cost:")[1].split("Age limit:")[0])
  end

  # Parse date from "When:" section (immediately before "Where:" section)
  def get_start_and_end_dates(n)
    get_event_datetimes(@description_xpath[n].text.split("When:")[1].split("Where:")[0])
  end

  # Date is always the same, but time is devided by Monday, April 6, 2015, 10:30 a.m. to 1 p.m.
  def split_into_start_and_end(string)
    super(string)
    string = string.split("to")
  end
end