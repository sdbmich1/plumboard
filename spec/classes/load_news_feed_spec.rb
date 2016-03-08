# encoding: UTF-8
require 'spec_helper'
require 'load_news_feed'
require 'nokogiri'
require 'rake'

describe LoadNewsFeed do
  before :all do
    # Load required records to database and instantiate LoadNewsFeed
    load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
    Rake::Task.define_task(:environment)
    Rake::Task["load_regions"].invoke
    Rake::Task["load_feeds"].invoke
    events = create :category, name: "Events", category_type_code: "Event", status: "active", pixi_type: "basic"
    jobs = create :category, name: "Jobs", category_type_code: "Jobs", status: "active", pixi_type: "basic"
    @lnf_obj = LoadNewsFeed.new
  end

  describe "initialize" do
    it "assigns default values" do
      expect(@lnf_obj.feed).to eq Feed.first
      expect(@lnf_obj.user_image).to eq "person_icon.jpg"
      expect(@lnf_obj.user_email).to eq "loadnewsfeed@pixiboard.com"
    end
  end

  describe "load!" do
    it "loads document" do
      expect(@lnf_obj.item_xpath).not_to be_nil
      expect(@lnf_obj.description_xpath).not_to be_nil
      expect(@lnf_obj.link_xpath).not_to be_nil
      expect(@lnf_obj.title_xpath).not_to be_nil
      expect(@lnf_obj.category).to be_nil
      expect(@lnf_obj.site).not_to be_nil
    end

    it "loads user" do
      expect(@lnf_obj.user.email).to eq @lnf_obj.user_email
      expect(@lnf_obj.user.first_name).to eq @lnf_obj.feed.description
      expect(@lnf_obj.user.last_name).to eq "Feed"
      expect(@lnf_obj.user.business_name).to eq @lnf_obj.feed.description
    end

    it "loads category-specific attributes for events" do
      event_feed = SDReaderFeed.new
      expect(event_feed.additional_datetimes).to be_nil
      expect(event_feed.event_type_words).not_to be_nil
    end

    it "loads category-specific attributes for jobs" do
      a = AfterCollegeFeed.new
      expect(a.additional_datetimes).to be_nil
      expect(a.job_type_codes).not_to be_nil
      expect(a.stock_images).not_to be_nil
      expect(a.company_xpath).not_to be_nil
      expect(a.jobtype_xpath).not_to be_nil
      expect(a.compensation_xpath).not_to be_nil
      expect(a.date_xpath).not_to be_nil
      expect(a.city_xpath).not_to be_nil
      expect(a.state_xpath).not_to be_nil
      expect(a.zip_xpath).not_to be_nil
      expect(a.country_xpath).not_to be_nil
      expect(a.ref_id_xpath).not_to be_nil
      expect(a.experience_xpath).not_to be_nil
      expect(a.education_xpath).not_to be_nil
    end
  end

  describe "download_feed" do
    it "downloads and unzips file to folder provided if feed is reachable" do
      @lnf_obj.feed = Feed.find_by_url("https://www.aftercollege.com/exports/pixiboard.zip")
      @lnf_obj.download_feed('db')
      expect(File.exists?(Rails.root.join('db', 'pixiboard.zip'))).to be_falsey
      expect(File.exists?(Rails.root.join('db', 'pixiboard.xml'))).to be_truthy
      File.delete(Rails.root.join('db', 'pixiboard.xml'))
    end

    it "returns nil and doesn't save anything to folder provided if feed is unreachable" do
      @lnf_obj.feed = Feed.new(url: "https://www.aftercollege.com/exports/nil.zip")
      doc = @lnf_obj.download_feed('db')
      expect(File.exists?(Rails.root.join('db', 'pixiboard.zip'))).to be_falsey
      expect(File.exists?(Rails.root.join('db', 'pixiboard.xml'))).to be_falsey
    end
  end

  describe "initialize_with_attrs" do
    it "creates LoadNewsFeed object with attrs provided" do
      expect(LoadNewsFeed.new_with_attrs({user_image: "test.png"}).user_image).to eq "test.png"
    end
  end

  describe "get_attrs" do
    it "gets necessary attributes" do
      attrs = @lnf_obj.get_attrs
      expect(attrs[:feed]).to eq @lnf_obj.feed
      expect(attrs[:user_image]).to eq @lnf_obj.user_image
      expect(attrs[:user_email]).to eq @lnf_obj.user_email
      expect(attrs[:category]).to eq @lnf_obj.category
      expect(attrs[:site]).to eq @lnf_obj.site
      expect(attrs[:user]).to eq @lnf_obj.user
      expect(attrs[:stock_images]).to eq @lnf_obj.stock_images
    end

    it "does not get Nokogiri::XML objects" do
      expect(@lnf_obj.get_attrs.keys).not_to include(:doc)
      expect(@lnf_obj.get_attrs.keys).not_to include(:@doc)
    end
  end

  describe "read_feeds" do
    it "calls add_listings on each LoadNewsFeed object" do
      feeds = [CourantFeed, StrangerFeed, SFExaminerFeed, SDReaderFeed, Sac365Feed]
      feeds.each { |feed| expect(feed).to receive :add_listings }
      Delayed::Worker.delay_jobs = false
      allow(LoadNewsFeed).to receive(:add_listings)
      LoadNewsFeed.read_feeds
    end
  end

  describe "add_listings" do
    it "calls add_listing for each entry in feed" do
      expect(@lnf_obj).to receive(:add_listing).exactly(@lnf_obj.item_xpath.count).times
      @lnf_obj.add_listings
    end

    it "does not attempt to load events if feed is unreachable" do
      @lnf_obj.doc = nil
      expect { @lnf_obj.add_listings }.not_to raise_error
    end
  end

  describe "get_description" do
    it "removes img tags from description" do
      urls = %w(http://www.thestranger.com/seattle/Rss.xml?category=13930221 
                http://www.sfexaminer.com/sanfrancisco/Rss.xml?section=2124643
                http://www.sacramento365.com/feeds/event/rss/
                http://www.nowplayingnashville.com/feeds/event/
                http://www.sandiegoreader.com/rss/events/)
      urls.each do |url|
        doc = Nokogiri::XML(open(url))
        @lnf_obj.description_xpath = doc.xpath("//item//description")
        expect(@lnf_obj.description_xpath[0].text).to include("img")
        expect(@lnf_obj.get_description(0)).not_to include("img")
      end
    end

    it "doesn't otherwise modify description" do
      url = "http://feeds.feedburner.com/courant-music"
      doc = Nokogiri::XML(open(url))
      @lnf_obj.description_xpath = doc.xpath("//item//description")
      expect(@lnf_obj.get_description(0)).to eq @lnf_obj.get_description(0)
    end
  end

  describe "process_description" do
    it "adds additional times and link" do
      @lnf_obj.additional_datetimes = "9 p.m. April 28"
      description = @lnf_obj.process_description("Description" , 0)
      expect(description).to include("Additional Times:")
      expect(description).to include("Details:")
    end

    it "handles invalid inputs" do
      @lnf_obj.additional_datetimes = "9 p.m. April 28"
      empty_str_description = @lnf_obj.process_description("", 0)
      expect(empty_str_description).to include("Additional Times:")
      expect(empty_str_description).to include("Details:")
      nil_description = @lnf_obj.process_description(nil, 0)
      expect(nil_description).to be_nil
    end
  end

  describe "remove_leading_spaces" do
    it "removes \n and \t" do
      expect(@lnf_obj.remove_leading_spaces("\n\n\t\tHello world")).to eq "Hello world"
    end

    it "handles invalid inputs" do
      expect(@lnf_obj.remove_leading_spaces("")).to eq ""
    end
  end

  describe "get_email_from_description" do
    it "gets email" do
      expect(@lnf_obj.get_email_from_description("user@pixiboard.com", "")).to eq "user@pixiboard.com"
    end

    it "removes punctuation" do
      expect(@lnf_obj.get_email_from_description("email me at user@pixiboard.com.", "")).to eq "user@pixiboard.com"
    end

    it "handles empty string" do
      expect(@lnf_obj.get_email_from_description("", "")).to be_nil
    end
  end

  describe "add_user" do
    it "should get feed's account if no email is provided" do
      expect(@lnf_obj.add_user("", "", nil)).to eq @lnf_obj.user
    end

    it "should find or create account corresponding to email provided" do
      user = @lnf_obj.add_user("", @lnf_obj.description_xpath[0].text, "user@pixiboard.com")
      expect(user.email).to eq "user@pixiboard.com"
      expect(user.first_name).to eq "User "
      expect(user.last_name).to eq "Feed"
      expect(user.business_name).to eq "User "
      expect(user.provider).to eq "pxb"
      expect(user.user_url).not_to be_nil
      expect(user.status).to eq "inactive"
      expect(user.user_type_code).to eq "BUS"
      expect(user.home_zip).to eq @lnf_obj.get_zip
    end
  end

  describe "save_user" do
    it "saves correct attributes" do
      user = @lnf_obj.save_user(@lnf_obj.user)
      expect(user.business_name).to eq user.first_name
      expect(user.provider).to eq "pxb"
      expect(user.user_url).not_to be_nil
      expect(user.status).to eq "inactive"
      expect(user.user_type_code).to eq 'BUS'
      expect(user.home_zip).to eq @lnf_obj.get_zip
    end

    it "copies first and last name when split" do
      @lnf_obj.user.last_name = "Test"
      user = @lnf_obj.save_user(@lnf_obj.user)
      expect(user.business_name).to eq user.first_name + user.last_name
    end
  end

  describe "get_zip" do
    it "returns zip code associated with site" do
      site = create :site, name: "SF Bay Area", site_type_code: "region"
      site.contacts.create FactoryGirl.attributes_for :contact, address: "Metro", city: "San Francisco", state: "CA", zip: "94101"
      @lnf_obj.site = site
      expect(@lnf_obj.get_zip).to eq "94101"
    end
  end

  describe "get_username" do
    it "gets username from email" do
      expect(@lnf_obj.get_username("user@pixiboard.com", "")).to eq "user"
    end

    it "only gets first 60 characters if name is longer than that" do
      name = "qwertyuiopasghjklzxcvbnmqwertyuiopasghjklzxcvbnmqwertyuiopasghjklzxcvbnm"
      expect(@lnf_obj.get_username(name + "@pixiboard.com", "")).to eq name[0..59]
    end
  end

  describe "handle_invalid_chars" do
    it "handles '&'" do
      expect(@lnf_obj.handle_invalid_chars("&")).to eq "and"
    end

    it "handles ':'" do
      expect(@lnf_obj.handle_invalid_chars(":")).to eq " -"
    end

    it "removes other invalid characters" do
      expect(@lnf_obj.handle_invalid_chars("$")).to eq ""
    end

    it "removes characters between parentheses" do
      expect(@lnf_obj.handle_invalid_chars("hello (world)")).to eq "hello "
    end
  end

  describe "split_username" do
    it "splits into first and last name" do
      first_name, last_name = @lnf_obj.split_username("Sacramento Italian Cultural Society")
      expect(first_name).to eq "Sacramento italian cultural "
      expect(last_name).to eq "Society"
    end

    it "assigns default last name" do
      first_name, last_name = @lnf_obj.split_username("Sacramento")
      expect(first_name).to eq "Sacramento "
      expect(last_name).to eq "Feed"
    end

    it "skips words that fail validation" do
      first_name, last_name = @lnf_obj.split_username("16th Annual Event")
      expect(first_name).not_to include("16th")
    end
  end

  describe "add_image" do
    it "should load from img tags" do
      lnf_obj = Sac365Feed.new("http://www.sacramento365.com/feeds/event/rss/")
      pic = Picture.new
      lnf_obj.add_image(pic, lnf_obj.get_img_loc_text(0))
      expect(pic.photo).not_to be_nil
    end
  end

  describe "add_user_image" do
    it "should load from @user_image" do
      pic = Picture.new
      @lnf_obj.user_image = "person_icon.jpg"
      @lnf_obj.add_user_image(pic)
      expect(pic.photo).not_to be_nil
    end
  end

  describe "check_image" do
    it "handles errors for invalid URLs" do
      pic = Picture.new
      expect(@lnf_obj.check_image(pic, "abc.cor42132")).to be_nil
    end
  end

  describe "get_event_type_code" do
    before :all do
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
      Rake::Task["load_event_types"].invoke
      @lnf_obj = SDReaderFeed.new    # need an events feed
    end

    it "gets event type code from description" do
      expect(@lnf_obj.get_event_type_code("concert", "")).to eq "perform"
    end

    it "searches title if not found in description" do
      expect(@lnf_obj.get_event_type_code("no codes here", "concert")).to eq "perform"
    end
  end

  describe "convert_to_event_type_code" do
    before :all do
      load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
      Rake::Task.define_task(:environment)
      Rake::Task["load_event_types"].invoke
      @lnf_obj = SDReaderFeed.new    # need an events feed
    end

    it "returns event type code" do
      expect(@lnf_obj.convert_to_event_type_code("concert")).to eq "perform"
    end

    it "recognizes plural of word in description" do
      expect(@lnf_obj.convert_to_event_type_code("concerts")).to eq "perform"
    end

    it "recognizes singular of word in description" do
      expect(@lnf_obj.convert_to_event_type_code("class")).to eq "session"
    end

    it "handles '/'" do
      expect(@lnf_obj.convert_to_event_type_code("gathering")).to eq "party"
    end

    it "handles spaces" do
      expect(@lnf_obj.convert_to_event_type_code("volunteer")).to eq "vol"
    end

    it "ignores words specified" do
      expect(@lnf_obj.convert_to_event_type_code("event")).not_to eq "sport"
    end

    it "returns 'other' if no event type is found" do
      expect(@lnf_obj.convert_to_event_type_code("test")).to eq "other"
    end
  end

  describe "get_price" do
    it "has default value of 0.0" do
      expect(@lnf_obj.get_price(0)).to eq 0.0
    end
  end

  describe "convert_to_price" do
    it "returns price" do
      expect(@lnf_obj.convert_to_price("$15")).to eq 15.0
    end

    it "returns price with cents" do
      expect(@lnf_obj.convert_to_price("$49.50")).to eq 49.5
    end

    it "handles dashes" do
      expect(@lnf_obj.convert_to_price("$40-$50.")).to eq 40.0
    end

    it "returns 0 for incorrect inputs" do
      expect(@lnf_obj.convert_to_price("Five")).to eq 0.0
    end
  end

  describe "get_start_and_end_dates" do
    it "has default values of nil for both start and end_date" do
      start_date, end_date = @lnf_obj.get_start_and_end_dates(0)
      expect(start_date).to be_nil
      expect(end_date).to be_nil
    end
  end

  def check_start_and_end(start_date, end_date, start_month, start_day, start_hour, start_min,end_month, end_day, end_hour, end_min)
    expect(start_date.month).to eq start_month
    expect(start_date.day).to eq start_day
    expect(start_date.hour).to eq start_hour
    expect(start_date.min).to eq start_min
    expect(end_date.month).to eq end_month
    expect(end_date.day).to eq end_day
    expect(end_date.hour).to eq end_hour
    expect(end_date.min).to eq end_min
  end

  # Most tests for distinct start and end dates are in spec files for
  # subclasses, as overriding split_into_start_and_end is necessary
  describe "get_event_datetimes" do
    it "should get single date" do
      start_date, end_date = @lnf_obj.get_event_datetimes("Tuesday, April 7")
      check_start_and_end(start_date, end_date, 4, 7, 0, 0, 4, 7, 23, 59)
    end

    it "should get single date with start time before it" do
      start_date, end_date = @lnf_obj.get_event_datetimes("9 p.m. April 10")
      check_start_and_end(start_date, end_date, 4, 10, 21, 0, 4, 10, 23, 59)
    end

    it "should get single date with time after it" do
      start_date, end_date = @lnf_obj.get_event_datetimes("Monday, April 6, 2015, noon")
      check_start_and_end(start_date, end_date, 4, 6, 12, 0, 4, 6, 23, 59)
    end

    it "handles invalid inputs" do
      start_date, end_date = @lnf_obj.get_event_datetimes("")
      expect(start_date).to be_nil
      expect(end_date).to be_nil
    end
  end

  describe "get_event_dates" do
    it "should get dates of form MM-DD-YYYY" do
      start_date, end_date = @lnf_obj.get_event_dates("04-08-2015 - 04-08-2015")
      check_start_and_end(start_date, end_date, 4, 8, 0, 0, 4, 8, 23, 59)
    end

    it "should return nil for invalid dates" do
      start_date, end_date = @lnf_obj.get_event_dates("100-01-2015 - 100-02-2015")
      expect(start_date).to be_nil
      expect(end_date).to be_nil
    end
  end

  describe "get_event_times" do
    before :all do
      @start_date, @end_date = @lnf_obj.get_event_dates("04-08-2015 - 04-08-2015")
    end

    it "should get start and end times" do
      start_date, end_date = @lnf_obj.get_event_times("Start Time(s): Wed 8pm-10pm ", @start_date, @end_date)
      check_start_and_end(start_date, end_date, 4, 8, 20, 0, 4, 8, 22, 0)
    end

    it "should get start time and assign default end time if end time is not available" do
      start_date, end_date = @lnf_obj.get_event_times("Start Time(s): Wed Noon ", @start_date, @end_date)
      check_start_and_end(start_date, end_date, 4, 8, 12, 0, 4, 8, 23, 59)
    end

    it "should assign default start and end times if neither are available" do
      start_date, end_date = @lnf_obj.get_event_times("Start Time(s): ", @start_date, @end_date)
      check_start_and_end(start_date, end_date, 4, 8, 0, 0, 4, 8, 23, 59)
    end
  end

  describe "split_into_start_and_end" do
    it "handles nil" do
      expect(@lnf_obj.split_into_start_and_end(nil)).to eq [""]
    end
  end

  describe "convert_to_datetime" do
    it "returns nil for invalid times" do
      expect(@lnf_obj.convert_to_datetime(nil)).to be_nil
      expect(@lnf_obj.convert_to_datetime("1")).to be_nil
    end

    it "returns correct time and date" do
      datetime = @lnf_obj.convert_to_datetime("9 p.m. April 1")
      expect(datetime.month).to eq 4
      expect(datetime.day).to eq 1
      expect(datetime.hour).to eq 21
      expect(datetime.min).to eq 0
    end

    it "should parse noon as 12 p.m." do
      expect(@lnf_obj.convert_to_datetime("noon").hour).to eq 12
    end

    it "should parse midnight as 12 a.m." do
      expect(@lnf_obj.convert_to_datetime("midnight").hour).to eq 0
    end

    it "should parse 'now' as today" do
      datetime = @lnf_obj.convert_to_datetime("now")
      expect(datetime.month).to eq DateTime.current.month
      expect(datetime.day).to eq DateTime.current.day
      expect(datetime.hour).to eq 0
      expect(datetime.min).to eq 0
    end

    it "should not parse 'may' as the month 'May'" do
      expect(@lnf_obj.convert_to_datetime("may")).to be_nil
    end
  end

  describe "has_end_time_without_date?" do
    it "returns true for time" do
      expect(@lnf_obj.has_end_time_without_date?("1 p.m.")).to be_truthy
    end

    it "returns true for special times" do
      expect(@lnf_obj.has_end_time_without_date?("noon")).to be_truthy
      expect(@lnf_obj.has_end_time_without_date?("midnight")).to be_truthy
    end

    it "returns false for time and date" do
      expect(@lnf_obj.has_end_time_without_date?("noon April 1")).to be_falsey
    end

    it "returns false for date" do
      expect(@lnf_obj.has_end_time_without_date?("April 1")).to be_falsey
    end

    it "returns false for invalid input" do
      expect(@lnf_obj.has_end_time_without_date?("a")).to be_falsey
    end
  end

  describe "fix_leading_time" do
    it "moves the time if it comes before the date" do
      expect(@lnf_obj.fix_leading_time('9 a.m. April 9')).to include 'April 9 9 a.m.'
      expect(@lnf_obj.fix_leading_time('9 am April 9')).to include 'April 9 9 am'
      expect(@lnf_obj.fix_leading_time('9 p.m. April 9')).to include 'April 9 9 p.m.'
      expect(@lnf_obj.fix_leading_time('9 pm April 9')).to include 'April 9 9 pm'
    end

    it "does not move the time if it comes after the date" do
      expect(@lnf_obj.fix_leading_time('April 9 9 a.m.')).to include 'April 9 9 a.m.'
      expect(@lnf_obj.fix_leading_time('April 9 9 am')).to include 'April 9 9 am'
      expect(@lnf_obj.fix_leading_time('April 9 9 p.m.')).to include 'April 9 9 p.m.'
      expect(@lnf_obj.fix_leading_time('April 9 9 pm')).to include 'April 9 9 pm'
    end

    it "returns date if no time is specified" do
      expect(@lnf_obj.fix_leading_time('April 9')).to include 'April 9'
    end
  end

  describe "handle_end_date_in_next_week" do
    it "advances week if end_date is in the week following start_date" do
      start_date, end_date = DateTime.civil(2015, 4, 18), DateTime.civil(2015, 4, 12)
      expect(@lnf_obj.handle_end_date_in_next_week(start_date, end_date)[1].day).to eq 19
    end

    it "does not advance week if end_date is in same week as start_date" do
      start_date, end_date = DateTime.civil(2015, 4, 17), DateTime.civil(2015, 4, 18)
      expect(@lnf_obj.handle_end_date_in_next_week(start_date, end_date)[1].day).to eq 18
    end

    it "handles nil" do
      start_date, end_date = @lnf_obj.handle_end_date_in_next_week(nil, nil)
      expect(start_date).to be_nil
      expect(end_date).to be_nil
    end
  end

  describe "handle_end_time_in_next_day" do
    it "advances day if end hour is in the day following start_date" do
      start_date, end_date = DateTime.civil(2015, 4, 18, 21, 0), DateTime.civil(2015, 4, 18, 1, 0)
      expect(@lnf_obj.handle_end_time_in_next_day(start_date, end_date)[1].day).to eq 19
    end

    it "does not advance day if end hour is in same day as start_date" do
      start_date, end_date = DateTime.civil(2015, 4, 18, 21, 0), DateTime.civil(2015, 4, 18, 23, 0)
      expect(@lnf_obj.handle_end_time_in_next_day(start_date, end_date)[1].day).to eq 18
    end

    it "handles nil" do
      start_date, end_date = @lnf_obj.handle_end_time_in_next_day(nil, nil)
      expect(start_date).to be_nil
      expect(end_date).to be_nil
    end
  end

  describe "set_default_end_time" do
    it "sets end time to 11:59 p.m." do
      end_time = @lnf_obj.set_default_end_time(DateTime.civil(2015, 4, 18, 0, 0))
      expect(end_time.hour).to eq 23
      expect(end_time.min).to eq 59
    end

    it "handles nil" do
      expect(@lnf_obj.set_default_end_time(nil)).to be_nil
    end
  end
end