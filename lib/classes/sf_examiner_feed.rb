class SFExaminerFeed < LoadNewsFeed
  def initialize
    @feed = Feed.find_by_url("http://www.sfexaminer.com/sanfrancisco/Rss.xml?section=2124643")
    @category = Category.find_by_name("Events")
    @user_image = "sf_examiner_logo.png"
    @user_email = "sfexaminerfeed@pixiboard.com"
    load!
  end

  # Title is the line after "IF YOU GO" and before "Where:"
  def get_title(n)
    description = Nokogiri::HTML(@description_xpath[n].text).text
    if description.include?("IF YOU GO")
      description = description.split("IF YOU GO")[1]
      if description.include?("Where")
        title = description.split("Where")[0]
        # Title must fit on single line
        title.gsub!("\n", " ").strip!
        title
      else
        super(n)
      end
    else
      super(n)
    end
  end

  # Description is everything before "IF YOU GO"
  def get_description(n)
    description = Nokogiri::HTML(super(n)).text
    if description.include?("IF YOU GO")
      description = description.split("IF YOU GO")[0]
      description = description.split(" ")[3..-1].join(" ")    # remove "by 'author name'"
      description.slice!("[ Subscribe to the comments on this story ] ")
      description
    else
      nil
    end
  end

  # Price is in description under either "Tickets:" or "Admission:". Both are before "Contact:" or "Contacts:"
  def get_price(n)
    description = Nokogiri::HTML(@description_xpath[n].text).text
    if description.include?("Tickets")
      convert_to_price(description.split("Tickets")[1].split("Contact")[0])
    elsif description.include?("Admission")
      convert_to_price(description.split("Admission")[1].split("Contact")[0])
    else
      0
    end
  end

  # This feed has several dates separated by commas or semicolons, so separate
  # by these characters and return an array of all the (start_date, end_date) pairs
  def get_start_and_end_dates(n)
    description = Nokogiri::HTML(@description_xpath[n].text).text
    if description.include?("IF YOU GO")
      description = description.split("IF YOU GO")[1]
      if description.include?("When" && "Tickets")
        description = description.split("When")[1].split("Tickets")[0]
        datetimes = description.gsub(";", ",").split(",")
        @additional_datetimes = datetimes[1..-1].join(",") if datetimes.size > 1
        get_event_datetimes(datetimes[0])
      else
        [nil, nil]
      end
    else
      [nil, nil]
    end
  end

  # Search for everything that separates start and end dates
  def split_into_start_and_end(string)
    super(string)
    string = string.split("-")
    string = string[0].split("and") if string.size == 1
    string = string[0].split("&") if string.size == 1
    string = string[0].split("through") if string.size == 1
    string = string[0].split("to") if string.size == 1
    string
  end
end