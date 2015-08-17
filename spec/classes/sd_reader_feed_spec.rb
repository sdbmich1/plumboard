require 'spec_helper'
require 'load_news_feed'
require 'nokogiri'
require 'rake'

describe SDReaderFeed do
  before :all do
    # Load required records to database and instantiate LoadNewsFeed
    load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
    Rake::Task.define_task(:environment)
    Rake::Task["load_regions"].invoke
    Rake::Task["load_feeds"].invoke
    create :category, name: "Events", category_type_code: "Event", status: "active", pixi_type: "basic"
    @lnf_obj = SDReaderFeed.new
  end

  describe "initialize" do
    it "assigns default values" do
      expect(@lnf_obj.feed).to eq Feed.find_by_url("http://www.sandiegoreader.com/rss/events/")
      expect(@lnf_obj.user_image).to eq "san_diego_reader_logo.png"
      expect(@lnf_obj.user_email).to eq "sdreaderfeed@pixiboard.com"
    end
  end

  describe "get_title" do
    it "should delete date" do
      doc = Nokogiri::XML(open("http://www.sandiegoreader.com/rss/events/"))
      @lnf_obj.title_xpath = doc.xpath("//item//title")
      date = Date.today.month.to_s + "/" + Date.today.day.to_s
      expect(@lnf_obj.title_xpath[0].text).to include(date)
      expect(@lnf_obj.get_description(0)).not_to include(date)
    end
  end

  describe "split_into_start_and_end" do
    it "should get start and end time separated by 'to'" do
      start_date, end_date = @lnf_obj.split_into_start_and_end("Monday, April 6, 2015, 10:30 a.m. to 1 p.m.")
      expect(start_date).to eq "Monday, April 6, 2015, 10:30 a.m. "
      expect(end_date).to eq " 1 p.m."
    end
  end
end