class StrangerFeed < LoadNewsFeed
  def initialize
    @feed = Feed.find_by_url("http://www.thestranger.com/seattle/Rss.xml?category=13930221")
    @category = Category.find_by_name("Events")
    @user_image = "the_stranger_logo.png"
    @user_email = "strangerfeed@pixiboard.com"
    load!
  end

  # Remove newspaper footer
  def get_description(n)
    description = super(n)
    description.slice!("[ Comment on this story ]")
    description.slice!("[ Subscribe to the comments on this story ]")
    description
  end

  # Price is in description
  def get_price(n)
    convert_to_price(@description_xpath[n].text)
  end

  # Start and end dates are in italicized part of description
  def get_start_and_end_dates(n)
    description = Nokogiri::HTML(@description_xpath[n].text)
    get_event_datetimes(description.xpath("//em").text)
  end

  # Remove address at the end, since the street number can get confused for a year.
  def split_into_start_and_end(string)
    super(string)
    string = string.split(",")[0..-2].join(",") if convert_to_datetime(string.split(",")[-1]).nil?   # address or date comes after a comma
    string = string.split("-")
    string.size == 1 ? string[0].split("through") : string
  end
end