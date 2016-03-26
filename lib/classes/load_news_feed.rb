require "open-uri"
require "nokogiri"
require "active_support/inflector"
require "zip"

class LoadNewsFeed
  attr_accessor :feed, :user_image, :user_email, :doc, :item_xpath,
                :description_xpath, :link_xpath, :title_xpath, :site,
                :category, :additional_datetimes, :user, :event_type_words,
                :company_xpath, :jobtype_xpath, :compensation_xpath, :date_xpath,
                :city_xpath, :state_xpath, :zip_xpath, :country_xpath,
                :ref_id_xpath, :experience_xpath, :education_xpath,
                :job_type_codes, :stock_images

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
    load_doc
    load_user
    load_category_specific_vars
  end

  # Load document and save values that are used frequently and are expensive to compute for large feeds
  def load_doc
    if @feed.url[-3..-1] == 'zip'
      download_feed('db')
      @doc = Nokogiri::XML(open(Rails.root.join('db', 'pixiboard.xml')))
    else
      @doc = Nokogiri::XML(open(URI.parse(@feed.url))) rescue nil
    end
    # Save these values because they are used frequently and are expensive to compute for large feeds
    if @doc
      @item_xpath = load_xpath("//item")
      @description_xpath = load_xpath("//item//description")
      @description_xpath = load_xpath("//description") if @description_xpath.blank?
      @link_xpath = load_xpath("//item//link")
      @link_xpath = load_xpath("//url") if @link_xpath.blank?
      @title_xpath = load_xpath("//item//title")
      @title_xpath = load_xpath("//title") if @title_xpath.blank?
      @title_xpath = load_xpath("//xmlns:title") if @title_xpath.blank?
    end
    # Save the feed's Site and category name so we don't have to query for them every time.
    @site = Site.find_by_id(@feed.site_id)
  end

  # Find or create account associated with @user_email
  def load_user
    @user = User.find_by_email(@user_email)
    if (@user.nil?)
      @user = User.new
      @user.email = @user_email
      @user.first_name, @user.last_name = @feed.description, "Feed"
      add_user_image(@user.pictures.build)
      save_user(@user)
    end
    @user.update_attribute(:status, 'inactive')
  end

  # Load variables that are only needed for a certain category
  def load_category_specific_vars
    name = @category ? @category.name : ''
    case name
    when 'Events'
      # Save words in the description of event type code
      @event_type_words = Hash.new
      EventType.find_each do |event_type|
        @event_type_words[event_type.code] = event_type.description.gsub(",", "").gsub("/", " ").split(" ")
      end
    when 'Jobs'
      load_job_vars
    end
    # If an event occurs at more than one time, use the first one for the event start and end times.
    # Store the rest in this variable as a string, and those times will be included in the description.
    # If the category isn't "Events", this variable should always be nil.
    @additional_datetimes = nil
  end

  # Load variables that are only needed for jobs
  def load_job_vars
    load_job_xpaths
    # Save job type codes and stock images to avoid querying for them every time
    @job_type_codes = Hash.new
    JobType.find_each do |job_type|
      # Store the job name in downcase because AfterCollege uses different
      # cases than us (e.g., Full-Time instead of Full-time)
      @job_type_codes[job_type.job_name.downcase] = job_type.code
    end
    @stock_images = Hash.new
    StockImage.find_each do |stock_image|
      @stock_images[stock_image.title] = stock_image.file_name
      # Store each individual word as a key for easier lookup
      words = stock_image.title.split(' / ')
      words.each { |word| @stock_images[word] = stock_image.file_name }
    end
  end

  # Load all AfterCollege xpaths
  def load_job_xpaths
    @company_xpath = @doc.xpath("//company")
    @jobtype_xpath = @doc.xpath("//jobtype")
    @compensation_xpath = @doc.xpath("//salary")
    @date_xpath = @doc.xpath("//date")
    @city_xpath = @doc.xpath("//city")
    @state_xpath = @doc.xpath("//state")
    @zip_xpath = @doc.xpath("//postalcode")
    @country_xpath = @doc.xpath("//country")
    @ref_id_xpath = @doc.xpath("//referencenumber")
    @experience_xpath = @doc.xpath("//experience")
    @education_xpath = @doc.xpath("//education")
  end

  # Download and extract a zip file containing the latest XML feed to the path provided.
  def download_feed(path)
    zip_file_path = Rails.root.join(path, @feed.url.split('/')[-1])
    download_zip(path, zip_file_path)
    extract_files(path, zip_file_path)
  end

  # Download the zip containing the latest XML feed to the path provided.
  def download_zip(path, zip_file_path)
    File.open(zip_file_path, 'wb') do |saved_file|
      open(@feed.url, 'rb') do |read_file|
        saved_file.write(read_file.read)
      end
    end
  end

  # Extract the files from the .zip in the path and delete the zip file.
  def extract_files(path, zip_file_path)
    # Line below throws Zip::Error if there was error downloading the file
    zip_file = Zip::File.open(zip_file_path) rescue nil
    if zip_file
      zip_file.entries.each do |entry|
        file_path = Rails.root.join(path, entry.to_s).to_s
        File.delete(file_path) if File.exists?(file_path)
        zip_file.extract(entry, file_path) { true }
      end
      zip_file.close
    end
    File.delete(zip_file_path)
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
    @category = attrs[:category]
    @site = attrs[:site]
    @user = User.find(attrs[:user_id])
  end

  # Get all attributes except Nokogiri objects, which can't be copied into the delayed job queue
  def get_attrs
    {
      feed: @feed,
      user_image: @user_image,
      user_email: @user_email,
      category: @category,
      site: @site,
      user_id: @user.id,
      stock_images: @stock_images
    }
  end

  # Load events from each feed
  def self.read_feeds
    feeds = [CourantFeed.new, StrangerFeed.new, SFExaminerFeed.new, SDReaderFeed.new,
             Sac365Feed.new("http://www.sacramento365.com/feeds/event/rss/"),
             Sac365Feed.new("http://www.nowplayingnashville.com/feeds/event/")]
    feeds.map(&:add_listings)
  end

  # Load jobs from After College feed
  def self.import_job_feed
    feed = AfterCollegeFeed.new
    feed.delete_expired_jobs
    feed.add_listings
  end

  # Load each item in the feed as a Listing if the URL was reached
  def add_listings
    num_listings = @title_xpath.try(:count) || 0
    for i in 0...num_listings
      add_listing(i)
    end
  end

  # The workflow of adding a listing is broken down into two parts: this method,
  # and add_listing_job, which is run in the delayed job queue.
  # This is done to speed up the task, so all computationally intensive values are
  # assigned in add_listing_job.
  # Use this method when:
  # 1. Using Nokogiri, since the delayed job queue doesn't accept Nokogiri objects
  # 2. The attributes may invalidate the Listing
  #    and can be found relatively quickly.
  #    For example, events that have already happened will fail validation,
  #    so don't bother adding them to the delayed job queue.
  # Use add_listing_job for:
  # 1. Doing database queries
  # 2. Uploading an image
  # since both take a long time when run on thousands of listings.
  # If you need Nokogiri-related values in add_listing_jobs, pass them as parameters.
  def add_listing(n, checked_existence=false)
    if (title = get_title(n))
      title = title[0..79]    # max length is 80 chars
      if checked_existence || !Listing.exists?(title: title)
        category_specific_attrs = get_category_specific_attrs(n)
        if category_specific_attrs[:start_date]
          if (description = process_description(get_description(n), n))
            attrs = get_listing_attrs(title, description, category_specific_attrs, n)
            item_text = @item_xpath.blank? ? '' : @item_xpath[n].text
            LoadNewsFeed.delay(queue: 'feed').add_listing_job(self.class,
              get_attrs, attrs, item_text, get_img_loc_text(n), @stock_images)
          end
        end
      end
    end
  end

  # See add_listing.
  # An additional note: some UTF-8 characters (for example: ′) cause an
  # "Illegal mix of collations" error, since certain parts of our database
  # collations are using Latin1 instead of UTF-8.
  # A long-term fix would be something like this:
  # http://airbladesoftware.com/notes/fixing-mysql-illegal-mix-of-collations/
  # However, since a very small number of XML entries have invalid characters,
  # they won't be added to the database for now, so this method rescues
  # database execution errors.
  def self.add_listing_job(lnf_class, lnf_obj_attrs, attrs, item_text, img_loc_text, stock_images)
    lnf_obj = lnf_class.new_with_attrs(lnf_obj_attrs)    # reconstruct original LoadNewsFeed object
    new_listing = TempListing.new(attrs)
    user_email = lnf_obj.get_email_from_description(new_listing.description, item_text)
    user = lnf_obj.add_user(item_text, img_loc_text, user_email)
    if user
      new_listing.seller_id = user.id
      new_listing.status = "approved"
      lnf_obj.add_image(new_listing.pictures.build, img_loc_text, stock_images)
      if new_listing.pictures.first.save && new_listing.pictures.first.photo? 
        begin
          saved = new_listing.save
        rescue ActiveRecord::StatementInvalid    # see collation error note above
          saved = false
        end
        if saved
          begin
            TempListingProcessor.new(new_listing).post_to_board
          rescue ActiveRecord::StatementInvalid
          end
        end
      end
    end
  end

  # Returns a Hash containing the attributes that will be used when making the TempListing
  def get_listing_attrs(title, description, category_specific_attrs, n)
    {
      title: title,
      description: description,
      price: get_price(n),
      quantity: 1,
      site_id: get_site_id(n) || @feed.site_id,
      category_id: @category.id,
      external_url: @link_xpath[n].text
    }.merge(category_specific_attrs)
  end

  # Get attributes of the item stored in the LoadNewsFeed object
  def get_item_attrs(n)
    attrs = { description_text: @description_xpath[n].text, image_loc_text: get_img_loc_text(n) }
    attrs[:item_text] = @item_xpath[n].text unless @item_xpath.blank?
    attrs[:stock_images] = @stock_images if @stock_images
    attrs
  end

  # Searches document for nth title element and returns its text
  # You will probably need to override this method when making a subclass.
  def get_title(n)
    @title_xpath[n].text
  end

  # This method removes images from the nth event's description.
  # You will probably need to override this method when making a subclass.
  def get_description(n)
    return nil unless @description_xpath[n]
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
    words.each do |word|
      if word.match(Devise::email_regexp)
        email = word.downcase
      # Remove punctuation at the end if it is there
      elsif word && !(word[-1] =~ /[A-Za-z]/) && word[0..-2].match(Devise::email_regexp)
        email = word[0..-2].downcase
      end
    end
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

  # Save user to database
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
    username.gsub!("365", "Three Sixty Five")    # "Sacramento 365" fails validation
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
  def add_image(pic, img_loc_text, stock_images=nil)
    description = Nokogiri::HTML(img_loc_text)
    image = description.xpath("//img")[0]
    begin
      ImageManager.parse_url_image(pic, URI.escape(image[:src]))
    rescue
      add_user_image(pic)
    end
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
    string = fix_leading_time(string)
    begin
      datetime = DateTime.parse(string)
    rescue ArgumentError, RangeError
      nil
    end
  end

  # Currently, DateTime.parse returns the wrong date and time if the time comes
  # before the date (for example, DateTime.parse("9 p.m. April 9")). This was
  # not the case when this class was originally written, so this is a patch
  # that moves the time to the end of the string.
  def fix_leading_time(string)
    ampm = nil
    %w(am a.m. pm p.m.).each { |t| ampm = t if string.include?(t) }
    return string unless ampm
    split_str = string.split(ampm)
    split_str.count == 1 ? (split_str[0] << ampm) : (split_str.reverse.join(' ') << ampm)
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

  # Returns a Hash containing all attributes that are specific to the Category
  def get_category_specific_attrs(n)
    case @category.name
    when 'Events';
      start_date, end_date = get_start_and_end_dates(n)
      start_date, end_date = nil, nil if start_date && start_date.to_date < Date.today
      result = { start_date: start_date, end_date: end_date,
        event_start_date: start_date, event_end_date: end_date,
        event_start_time: start_date, event_end_time: end_date }
      if @description_xpath[n] && @title_xpath[n]
        result[:event_type_code] = get_event_type_code(@description_xpath[n].text, @title_xpath[n].text)
      end
      result
    when 'Jobs';
      { start_date: convert_to_datetime(@date_xpath[n].text), job_type_code: get_job_type_code(n),
        compensation: get_compensation(n), ref_id: get_ref_id(n) }
    end
  end

  # Return the site ID of the n'th entry.
  # By default, this method returns nil, and @feed.site_id is used when the TempListing/Listing objects are created.
  # Override this method if you want to read the Site from the XML entries instead.
  def get_site_id(n)
    nil
  end

  # Return the job type code of the n'th job.
  def get_job_type_code(n)
    job_type = @jobtype_xpath[n].text.downcase
    job_type.gsub!('internship', 'intern')
    @job_type_codes[job_type]
  end

  # Return the compensation of the n'th job.
  def get_compensation(n)
    @compensation_xpath[n].text
  end

  # Return the ref_id of the n'th job
  def get_ref_id(n)
    @ref_id_xpath[n].text
  end
end
