require 'spec_helper'
require 'load_news_feed'
require 'nokogiri'
require 'rake'

describe CourantFeed do
  before :all do
    # Load required records to database and instantiate LoadNewsFeed
    load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
    Rake::Task.define_task(:environment)
    Rake::Task["load_regions"].invoke
    Rake::Task["load_feeds"].invoke
    create :category, name: "Events", category_type_code: "Event", status: "active", pixi_type: "basic"
    @lnf_obj = CourantFeed.new
  end

  describe "initialize" do
    it "assigns default values" do
      expect(@lnf_obj.feed).to eq Feed.find_by_url("http://feeds.feedburner.com/courant-music")
      expect(@lnf_obj.user_image).to eq "hartford_courant_logo.png"
      expect(@lnf_obj.user_email).to eq "courantfeed@pixiboard.com"
    end
  end

  describe "add_image" do
    it "should load from media:content element" do
      pic = Picture.new
      @lnf_obj.add_image(pic, 'http://www.trbimg.com/img-55cb7f03/turbine/hc-sound-check-0813-20150812/600')
      expect(pic.photo).not_to be_nil
    end
  end
end