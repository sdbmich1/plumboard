class CourantFeed < LoadNewsFeed
  def initialize
    @feed = Feed.find_by_url("http://feeds.feedburner.com/courant-music")
    @user_image = "hartford_courant_logo.png"
    @user_email = "courantfeed@pixiboard.com"
    load!
  end

  # Image is in media:content element
  def get_img_loc_text(n)
    img_loc = @doc.xpath("//item//media:content")[n]
    img_loc[:url] if img_loc
  end

  def add_image(pic, img_loc_text)
    check_image(pic, img_loc_text + "?fmt=jpg") if img_loc_text
  end

  # Price is in description
  def get_price(n)
    convert_to_price(@description_xpath[n].text)
  end

  # Parse first date in description as DateTime object and infer end date
  def get_start_and_end_dates(n)
    description = @description_xpath[n].text
    datetime = convert_to_datetime(description)
    [datetime, set_default_end_time(datetime)]
  end
end