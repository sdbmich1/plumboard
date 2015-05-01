require 'spec_helper'
require 'load_news_feed'
require 'nokogiri'
require 'rake'

describe SFExaminerFeed do
  before :all do
    # Load required records to database and instantiate LoadNewsFeed
    load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
    Rake::Task.define_task(:environment)
    Rake::Task["load_regions"].invoke
    Rake::Task["load_feeds"].invoke
    create :category, name: "Events", category_type_code: "Event", status: "active", pixi_type: "basic"
    @lnf_obj = SFExaminerFeed.new
  end

  describe "initialize" do
    it "assigns default values" do
      expect(@lnf_obj.feed).to eq Feed.find_by_url("http://www.sfexaminer.com/sanfrancisco/Rss.xml?section=2124643")
      expect(@lnf_obj.user_image).to eq "sf_examiner_logo.png"
      expect(@lnf_obj.user_email).to eq "sfexaminerfeed@pixiboard.com"
    end
  end

  describe "split_into_start_and_end" do
    it "should split two dates separated by 'through'" do
      start_date, end_date = @lnf_obj.split_into_start_and_end("Friday, April 10 through Saturday, April 11")
      expect(start_date).to eq "Friday, April 10 "
      expect(end_date).to eq " Saturday, April 11"
    end

    it "should split two dates separated by '-'" do
      start_date, end_date = @lnf_obj.split_into_start_and_end("Thursday, April 2 - Saturday, April 4")
      expect(start_date).to eq "Thursday, April 2 "
      expect(end_date).to eq " Saturday, April 4"
    end

    it "should get two dates separated by '&'" do
      start_date, end_date = @lnf_obj.split_into_start_and_end("Friday, August 14 & Saturday, August 15")
      expect(start_date).to eq "Friday, August 14 "
      expect(end_date).to eq " Saturday, August 15"
    end

    it "should get two dates separated by 'to'" do
      start_date, end_date = @lnf_obj.split_into_start_and_end("August 14 to August 15")
      expect(start_date).to eq "August 14 "
      expect(end_date).to eq " August 15"
    end

    it "should get dates separated by 'and' with start time" do
      start_date, end_date = @lnf_obj.split_into_start_and_end("7:30 p.m. April 2 and April 4")
      expect(start_date).to eq "7:30 p.m. April 2 "
      expect(end_date).to eq " April 4"
    end
  end
end