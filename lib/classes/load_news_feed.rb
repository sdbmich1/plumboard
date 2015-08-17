require "open-uri"
require "nokogiri"
require "active_support/inflector"

class LoadNewsFeed
  attr_accessor :feed, :user_image, :user_email, :doc, :item_xpath,
                :description_xpath, :link_xpath, :title_xpath, :category_id,
                :site, :additional_datetimes, :user, :event_type_words

  # This method contains default values for @feed, @user_image, and @user_email.
  # Override them when making a subclass and the call load!.
  # @feed:       a Feed object
  # @user_image: the name of the file used as the profile picture of the feed's default User account
  # @user_email: the email associated with the default account
  def initialize
    @feed = Feed.first
    @user_image = "person_icon.jpg"
    @user_email = "loadnewsfeed@pixiboard.com"
    load!
  end

  # Load feed's URL as a Nokogiri::XML object and save some useful values
  def load!
    @doc = Nokogiri::XML(open(URI.parse(@feed.url))) rescue nil
    # Save these values because they are used frequently and are expensive to compute for large feeds
    if @doc
      @item_xpath = load_xpath("//item")
      @description_xpath = load_xpath("//item//description")
      @link_xpath = load_xpath("//item//link")
      @title_xpath = load_xpath("//item//title")
      @title_xpath ||= load_xpath("//xmlns:title")
    end
    # Save the "Events" category ID and the feed's Site so we don't have to query for them every time
    @category_id = Category.find_by_name("Events").id
    @site = Site.find_by_id(@feed.site_id)
    # Save account associated with @user_email
    @user = User.find_by_email(@user_email)
    if (@user.nil?)
      @user = User.new
      @user.email = @user_email
      @user.first_name, @user.last_name = @feed.description, "Feed"
      add_user_image(@user.pictures.build)
      save_user(@user)
    end
    # Save words in the description of event type code
    @event_type_words = Hash.new
    EventType.find_each do |event_type|
      @event_type_words[event_type.code] = event_type.description.gsub(",", "").gsub("/", " ").split(" ")
    end
    # If an event occurs at more than one time, use the first one for the event start and end times.
    # Store the rest in this variable as a string, and those times will be included in the description.
    @additional_datetimes = nil
  end

  # Return the xpath if it exists in the document, and nil if it does not
  def load_xpath(path)
    begin
      @doc.xpath(path)
    rescue Nokogiri::XML::XPath::SyntaxError
      nil
    end
  end

  # Boilerplate code for overriding #new, but it calls initialize_with_attrs instead
  def self.new_with_attrs(attrs)
    object = allocate
    object.initialize_with_attrs(attrs)
    object
  end

  # Load LoadNewsFeed object attributes from the attrs hash provided.
  # This method is called from the delayed job queue to recreate the
  # original LoadNewsFeed object without Nokogiri objects.
  def initialize_with_attrs(attrs)
    @feed = attrs[:feed]
    @user_image = attrs[:user_image]
    @user_email = attrs[:user_email]
    @category_id = attrs[:category_id]
    @site = attrs[:site]
    @user = attrs[:user]
  end

  # Get all attributes except Nokogiri objects, which can't be copied into the delayed job queue
  def get_attrs
    {
      feed: @feed,
      user_image: @user_image,
      user_email: @user_email,
      category_id: @category_id,
      site: @site,
      user: @user
    }
  end

  # Load events from each feed
  def self.read_feeds
    feeds = [CourantFeed.new, StrangerFeed.new, SFExaminerFeed.new, SDReaderFeed.new,
             Sac365Feed.new("http://www.sacramento365.com/feeds/event/rss/"),
             Sac365Feed.new("http://www.nowplayingnashville.com/feeds/event/")]
    feeds.map(&:load_events)
  end

  # Load each event in the feed if the URL was reached
  def load_events
    if @doc
      for i in 0..@item_xpath.count-1
        add_event(i)
      end
    end
  end

  # The workflow of adding an event is broken down into two parts: this method,
  # and add_event_job, which is run in the delayed job queue.
  # This is done to speed up the task, so all computationally intensive values are
  # assigned in add_event_job.
  # Use this method when:
  # 1. Using Nokogiri, since the delayed job queue doesn't accept Nokogiri objects
  # 2. The attributes may invalidate the Listing
  #    and can be found relatively quickly.
  #    For example, events that have already happened will fail validation,
  #    so don't bother adding them to the delayed job queue.
  # Use add_event_job for:
  # 1. Doing database queries
  # 2. Uploading an image
  # since both take a long time when run on thousands of events.
  # If you need Nokogiri-related values in add_event_jobs, pass them as parameters.
  def add_event(n)
    if (title = get_title(n))
      title = title[0..79]    # max length is 80 chars
      unless Listing.exists?({title: title})
        start_date, end_date = get_start_and_end_dates(n)
        if start_date && end_date && start_date.to_date >= Date.today
          price = get_price(n)
          if (description = process_description(get_description(n), n))
            attrs = get_event_attrs(title, description, price, start_date, end_date, n)
            LoadNewsFeed.delay(queue: "feeds").add_event_job(self.class, get_attrs, attrs, @item_xpath[n].text,
              @description_xpath[n].text, get_img_loc_text(n))
          end
        end
      end
    end
  end

  # See add_event.
  # An additional note: some UTF-8 characters (for example: ′) cause an
  # "Illegal mix of collations" error, since certain parts of our database
  # collations are using Latin1 instead of UTF-8.
  # A long-term fix would be something like this:
  # http://airbladesoftware.com/notes/fixing-mysql-illegal-mix-of-collations/
  # However, since a very small number of events have invalid characters,
  # they won't be added to the database for now, so this method rescues
  # database execution errors.
  def self.add_event_job(lnf_class, lnf_obj_attrs, attrs, item_text,
    description_text, img_loc_text)
    lnf_obj = lnf_class.new_with_attrs(lnf_obj_attrs)    # reconstruct original LoadNewsFeed object
    new_event = TempListing.new(attrs)
    user_email = lnf_obj.get_email_from_description(new_event.description, item_text)
    user = lnf_obj.add_user(item_text, img_loc_text, user_email)
    if user
      new_event.seller_id = user.id
      new_event.status = "approved"
      lnf_obj.add_image(new_event.pictures.build, img_loc_text)
      if new_event.pictures.first.save && new_event.pictures.first.photo? 
        begin
          saved_event = new_event.save
        rescue ActiveRecord::StatementInvalid    # see collation error note above
          saved_event = false
        end
        if saved_event
          begin
            TempListingProcessor.new(new_event).post_to_board
          rescue ActiveRecord::StatementInvalid
          end
        end
      end
    end
  end

  # Returns a Hash containing the attributes that will be used when making the event's TempListing
  def get_event_attrs(title, description, price, start_date, end_date, n)
    {
      :title => title,
      :description => description,
      :price => price,
      :quantity => 1,
      :start_date => start_date,
      :end_date => end_date,
      :event_start_date => start_date,
      :event_end_date => end_date,
      :event_start_time => start_date,
      :event_end_time => end_date,
      :site_id => @feed.site_id,
      :category_id => @category_id,
      :event_type_code => get_event_type_code(@description_xpath[n].text, @title_xpath[n].text)
    }
  end

  # Searches document for nth title element and returns its text
  # You will probably need to override this method when making a subclass.
  def get_title(n)
    @title_xpath[n].text
  end

  # This method removes images from the nth event's description.
  # You will probably need to override this method when making a subclass.
  def get_description(n)
    fragment = Nokogiri::HTML.fragment(@description_xpath[n].text)
    fragment.search("//img").remove
    fragment.text
  end

  # This method adds additional date/time information and a link to the article.
  def process_description(description, n)
    if description
      if @additional_datetimes
        description += "\n\nAdditional Times: " + @additional_datetimes
        @additional_datetimes = nil    # don't post additional times for next event
      end
      description += "\n\nDetails: " + @link_xpath[n].text if @link_xpath
      description
    end
  end

  # Removes all \n or \t characters only at the start of the string
  def remove_leading_spaces(string)
    for i in 0..string.size-1
      return string[i..-1] if string[i] != "\n" && string[i] != "\t"
    end
    string
  end

  # Read each word in description and return it if it's an email.
  # item_text is used in subclasses.
  def get_email_from_description(description, item_text)
    words = description.split(" ")
    email = nil
    words.each { |word| email = word.downcase if word.match(Devise::email_regexp) }
    # Remove punctuation at the end if it is there
    email = email[0..-2] if email && !(email[-1] =~ /[A-Za-z]/)
    email
  end

  # If email is provided, the user with that email will be used.
  # Otherwise, use the email associated with the feed.
  def add_user(item_text, img_loc_text, email=nil)
    return @user if email.nil?
    if (user = User.find_by_email(email))
      user
    else
      user = User.new
      user.email = email
      name = get_username(email, item_text)
      user.first_name, user.last_name = split_username(name)
      add_image(user.pictures.build, img_loc_text)
      save_user(user)
    end
  end

  def save_user(user)
    if user.last_name == "Feed"
      user.business_name = user.first_name
    else
      user.business_name = user.first_name + user.last_name
    end
    user.provider = "pxb"
    user.user_url = user.name
    user.status = "inactive"
    user.user_type_code = 'BUS'
    user.home_zip = get_zip
    user.skip_confirmation!
    user.save ? user : nil
  end

  # Return the zip code associated with @site
  def get_zip
    [@site.contacts.first.city, @site.contacts.first.state].join(", ").to_zip.first
  end

  # Returns the username for the account posting the event.
  # By default, this uses everything before the "@" sign.
  # Override this method if the name is available elsewhere.
  def get_username(email, item_text)
    handle_invalid_chars(email.split("@")[0][0..59])
  end

  # Remove/substitute any characters that would fail validation
  def handle_invalid_chars(username)
    # Substitute invalid characters with valid equivalents
    username.gsub!("&", "and")
    username.gsub!(":", " -")
    # Remove everything inbetween parentheses
    while username.gsub!(/\([^()]*?\)/, ''); end
    # Remove other invalid characters
    username.split("").each do |char|
      username_regex = /['-., a-zA-Z0-9]+$/i
      username.gsub!(char, "") unless username_regex.match(char)
    end
    username
  end

  # Split a username longer than 30 characters into a first and last name
  def split_username(username)
    first_name, last_name = "", ""
    words, i = username.split(" "), 0
    # First names / business names must start with a capital letter
    words = words[1..-1] while !(/[a-zA-Z]/.match(words[0][0]))
    # Read as many words into first_name as will fit, then do the same for last_name
    while words[i] && (first_name + words[i]).size < 30
      first_name += words[i] + " "
      i += 1
    end
    while words[i] && (last_name + words[i]).size < 30
      last_name += words[i] + " "
      i += 1
    end
    # [0..-2] to remove last space at end
    last_name.blank? ? [first_name.capitalize, "Feed"] : [first_name.capitalize, last_name[0..-2].capitalize]
  end

  # Search for image in description.
  # Override if image is located elsewhere.
  def get_img_loc_text(n)
    @description_xpath[n].text
  end

  # Scan description for <img src=IMAGE URL>
  # Override this if the image is located elsewhere
  def add_image(pic, img_loc_text)
    description = Nokogiri::HTML(img_loc_text)
    image = description.xpath("//img")[0]
    check_image(pic, URI.escape(image[:src])) if image
  end

  # Assigns pic.photo to @user_image
  def add_user_image(pic)
    pic.photo = File.new(Rails.root.join("app/assets/images/", @user_image))
  end

  # Handle errors when attempting to load the image
  def check_image(pic, url)
    ImageManager.parse_url_image(pic, url) rescue nil
  end

  # Search description_text and title_text for event type
  def get_event_type_code(description_text, title_text)
    code = convert_to_event_type_code(description_text)
    code = convert_to_event_type_code(title_text) if code == "other"
    code
  end

  # Scan string for any word in an event type description.
  # Return the event type code if a word is found, and return "other" if not.
  # Ignore words that could trigger false positives.
  def convert_to_event_type_code(string)
    string.downcase!
    ignored_words = %w(event events activity activities center centers service services social private public other)
    @event_type_words.each do |event_type_code, words|
      words.each do |word| 
        if !ignored_words.include?(word) && (string.include?(word) ||
          string.include?(word.singularize) || string.include?(word.pluralize))
          return event_type_code
        end
      end
    end
    "other"
  end

  # Override this method to look for the price in the correct section of
  # each feed and call convert_to_price on it
  def get_price(n)
    0.0
  end

  # Find the price in string using a regex and return the price as a float
  def convert_to_price(string)
    price_string = string.gsub(",", "")
    price = /\$(\d+\.\d+)/.match(price_string)    # $XX.XX
    price ||= /\$(\d+)/.match(price_string)       # $XX
    price.nil? ? 0.0 : price[0][1..-1].to_f   # [1..-1] to remove the dollar sign
  end

  # Call the appropriate method and pass the correct string to return
  # [start_date, end_date] of the nth event in @doc.
  # To override this, find where start and end dates are stored and call either
  # get_event_datetimes (if dates and times are stored in the same string) or
  # get_event_dates and get_event_times (if dates and times are in different strings).
  def get_start_and_end_dates(n)
    [nil, nil]
  end

  # This method attempts to read start and end dates from the event description and parse them as DateTime objects.
  # It will load the start and end times into these objects if available.
  # If not, the start time is assumed to be midnight and the end time is assumed to be 11:59 p.m.
  def get_event_datetimes(string)
    string = split_into_start_and_end(string)
    # Check if end date/time was found
    if string.size == 0
      [nil, nil]
    elsif string.size == 1
      [convert_to_datetime(string[0]), set_default_end_time(convert_to_datetime(string[0]))]
    elsif has_end_time_without_date?(string[1])
      # If the string has an end time but no end date, copy the start date into the end date.
      # For example, the end date/time for "April 6, 2015, 10:30 a.m. to 1 p.m." is parsed as "1 p.m.",
      # so April 6th must be specified.
      start_date, end_date = convert_to_datetime(string[0]), convert_to_datetime(string[1])
      if start_date
        end_date = end_date.change({day: start_date.day, month: start_date.month, year: start_date.year})
        handle_end_date_in_next_week(start_date, end_date)
      end
    else
      handle_end_date_in_next_week(convert_to_datetime(string[0]), set_default_end_time(convert_to_datetime(string[1])))
    end
  end

  # Gets event dates of the form MM-DD-YYYY.
  # If the events are not of this form or the string could include a time, use get_event_datetimes instead.
  def get_event_dates(string)
    string = string.split(" - ")
    begin
      [DateTime.strptime(string[0], "%m-%d-%Y"), set_default_end_time(DateTime.strptime(string[1], "%m-%d-%Y"))]
    rescue ArgumentError
      [nil, nil]
    end
  end

  # Reads event times when they are stored separately from event dates.
  # For now, these times are of the form "Start Time(s): START_TIME" or "Start Time(s): START_TIME-END_TIME".
  # If times are found, the method updates the hour and minute of start_date and end_date
  # and returns the new values. Otherwise, start_date and end_date are returned unmodified.
  def get_event_times(string, start_date, end_date)
    split_str = string.split("Start Time(s): ")
    if split_str.size > 1
      split_str = split_str[1].split("-")
      if split_str.size == 1
        # String only contains a start time
        time = convert_to_datetime(split_str[0])
        [start_date.change({hour: time.hour, min: time.min}), end_date] if time
      else
        start_time, end_time = convert_to_datetime(split_str[0]), convert_to_datetime(split_str[1])
        start_date = start_date.change({hour: start_time.hour, min: start_time.min}) if start_time
        end_date = end_date.change({hour: end_time.hour, min: end_time.min}) if end_time
        handle_end_time_in_next_day(start_date, end_date)
      end
    else
      [start_date, end_date]
    end
  end

  # This method attempts to split string into start and end dates.
  # Since different feeds do this differently, you need to override this
  # if you're calling get_event_datetimes.
  def split_into_start_and_end(string)
    string.nil? ? [""] : [string]
  end

  # Convert a string representing a date into a DateTime object
  def convert_to_datetime(string)
    # Return nil if string is nil
    return nil unless string
    # Remove the lowercase "may" (for example, "Event times may change")
    # from the string, as it will incorrectly be parsed as the month of May.
    string.slice!("may") if string.include?("may")
    string.downcase!
    # Parse 'now' as today's date at midnight
    return DateTime.current.change({hour: 0, min: 0}) if string.include?("now")
    string.gsub!("midnight", "12 a.m.")
    string.gsub!("noon", "12 p.m.")
    # Handle invalid dates by returning nil
    begin
      datetime = DateTime.parse(string)
    rescue ArgumentError
      nil
    end
  end

  # Return true if string can successfully be converted into a time, but not a date
  def has_end_time_without_date?(string)
    has_date, has_time = true, true
    begin
      Date.parse(string)
    rescue ArgumentError
      has_date = false
    end
    begin
      Time.parse(string)
    rescue ArgumentError
      has_time = string.downcase.include?("noon") || string.downcase.include?("midnight")
    end
    has_time && !has_date
  end

  # This method handles errors that occur when the end date is in the week following the start date.
  # For example, if an event goes from Saturday (4/18/2015) to Sunday (4/19/2015),
  # and the current week is 4/12/2015 - 4/18/2015, Sunday will be incorrectly parsed as 4/12/2015.
  def handle_end_date_in_next_week(start_date, end_date)
    if start_date && end_date
      end_date += 7.days if start_date.day > end_date.day
    end
    [start_date, end_date]
  end

  # This method handles errors that occur when the end time is in following day.
  # For example, if we have 'Start Time(s): Friday 9pm - 1:30am',
  # the end time would incorrectly be parsed as Friday at 1:30 am instead of Saturday.
  def handle_end_time_in_next_day(start_date, end_date)
    if start_date && end_date
      end_date += 1.days if end_date.hour < start_date.hour
    end
    [start_date, end_date]
  end

  # Sets end time to default value of 11:59 p.m.
  def set_default_end_time(end_time)
    end_time = end_time.change({hour: 23, min: 59}) if end_time
  end
end