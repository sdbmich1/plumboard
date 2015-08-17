require 'spec_helper'
require 'load_news_feed'
require 'nokogiri'
require 'rake'

describe Sac365Feed do
  before :all do
    # Load required records to database and instantiate LoadNewsFeed
    load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
    Rake::Task.define_task(:environment)
    Rake::Task["load_regions"].invoke
    Rake::Task["load_feeds"].invoke
    create :category, name: "Events", category_type_code: "Event", status: "active", pixi_type: "basic"
    @sac_lnf_obj = Sac365Feed.new("http://www.sacramento365.com/feeds/event/rss/")
    @nash_lnf_obj = Sac365Feed.new("http://www.nowplayingnashville.com/feeds/event/")
  end

  describe "initialize" do
    it "assigns Sacramento 365 values" do
      expect(@sac_lnf_obj.feed).to eq Feed.find_by_url("http://www.sacramento365.com/feeds/event/rss/")
      expect(@sac_lnf_obj.user_image).to eq "sac365_logo.png"
      expect(@sac_lnf_obj.user_email).to eq "sac365feed@pixiboard.com"
    end

    it "assigns Now Playing Nashville values" do
      expect(@nash_lnf_obj.feed).to eq Feed.find_by_url("http://www.nowplayingnashville.com/feeds/event/")
      expect(@nash_lnf_obj.user_image).to eq "now_playing_nashville_logo.png"
      expect(@nash_lnf_obj.user_email).to eq "nowplayingnashvillefeed@pixiboard.com"
    end
  end

  describe "get_description" do
    it "removes <dd> tags from description" do
      doc = Nokogiri::XML(open("http://www.sacramento365.com/feeds/event/rss/"))
      @sac_lnf_obj.description_xpath = doc.xpath("//item//description")
      expect(@sac_lnf_obj.description_xpath[0].text).to include("<dd>")
      expect(@sac_lnf_obj.get_description(0)).not_to include("<dd>")
      doc = Nokogiri::XML(open("http://www.nowplayingnashville.com/feeds/event/"))
      @nash_lnf_obj.description_xpath = doc.xpath("//item//description")
      expect(@nash_lnf_obj.description_xpath[0].text).to include("<dd>")
      expect(@nash_lnf_obj.get_description(0)).not_to include("<dd>")
    end
  end

  describe "get_email_from_description" do
    it "gets email" do
      test_event = "
        <item>
          <title><![CDATA[Island of Black and White]]></title>
          <link><![CDATA[http://www.sacramento365.com/event/detail/441909437]]></link>
          <guid><![CDATA[http://www.sacramento365.com/event/detail/441909437]]></guid>
          <description><![CDATA[<img
            src\"http://www.sacramento365.com/sites/sacramento365.com/images/event/441909437/island_of_medium.jpg\"
            alt=\"Island of Black and White\">
          <dd>Island of Black and White</dd>
          <dd>04-30-2015 - 04-30-2015</dd>
          <dd>4</dd>
          <dd>Torch Club</dd>
          <dd>http://www.torchclub.net/</dd>
          <dd>Torch Club - 904 15th Street   Sacramento CA 95814</dd>
          <dd>Admission: $6
              Ages 21+</dd>
          <dd></dd>
          <dd>(916) 443-2797</dd>
          <dd>marina@torchclub.net</dd>
          <dd></dd>
          <dd>Start Time(s): Thur 9pm
        </dd>  
        Island of Black and White first appeared on the music scene in California in
        2004 Their music is a sweet, humble yet raw blend of acoustic rock, funky
        reggae, and soulful blues It is a mixture like no other The duet, sometimes
        quartet, exerts high energy performances while frequenting local and out of
        town venues, restaurants, bars, coffee shops, music festivals, and various events

        The unique sound of Island of Black and White today captures the attention of
        those young and old, with Chris Haislet on guitar, keyboard, accordion,
        melodica, flute, and vocals; with Nawal Alwareeth on drums and vocals It
        is apparent for anyone watching that the band shares an immense love for
        music Not only does the band enjoy playing, but their incredible performances
        engage all who listen]]>
        </description>
        <pubDate><![CDATA[Wed, 01 Apr 2015 00:00:00 -0700]]></pubDate>
      </item>"
      expect(@sac_lnf_obj.get_email_from_description("", test_event)).to eq "marina@torchclub.net"
    end

    it "returns nil if email is not found" do
      expect(@sac_lnf_obj.get_email_from_description("", "")).to be_nil
    end
  end

  describe "convert_to_price" do
    it "infers decimal point" do
      expect(@sac_lnf_obj.convert_to_price("$1500")).to eq 15.0
    end

    it "does not infer decimal point for values less than $1000" do
      expect(@sac_lnf_obj.convert_to_price("$900")).to eq 900.0
    end

    it "does not infer decimal point if there's a comma" do
      expect(@sac_lnf_obj.convert_to_price("$1,500")).to eq 1500.0
    end
  end
end