require 'spec_helper'
require 'load_news_feed'
require 'nokogiri'
require 'rake'

describe AfterCollegeFeed do
  before :all do
    # Load required records to database and instantiate LoadNewsFeed
    load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
    Rake::Task.define_task(:environment)
    Rake::Task["load_regions"].invoke
    Rake::Task["load_feeds"].invoke
    Rake::Task["load_categories"].invoke
    Rake::Task["load_stock_images"].invoke
    @lnf_obj = AfterCollegeFeed.new
  end

  describe "initialize" do
    it "assigns default values" do
      expect(@lnf_obj.feed).to eq Feed.find_by_url("https://www.aftercollege.com/exports/pixiboard.zip")
      expect(@lnf_obj.user_image).to eq "aftercollege.png"
      expect(@lnf_obj.user_email).to eq "support@aftercollege.com"
    end
  end

  describe "add_image" do
    it "assigns pic.photo" do
      pic = Picture.new
      @lnf_obj.add_image(pic, 'Programmer')
      expect(pic.photo).not_to be_nil
    end
  end

  describe "get_email_from_description" do
    it "should always return nil" do
      expect(@lnf_obj.get_email_from_description('', '')).to be_nil
    end
  end

  describe "get_image_from_set" do
    it "returns stock image for 'other' if the set is empty" do
      expect(@lnf_obj.get_image_from_set(Set.new, '')).to eq 'werehiring.jpg'
    end
    it "returns image if there's only one element in set" do
      expect(@lnf_obj.get_image_from_set(Set.new(['Programmer']), '')).to eq 'Computer.jpg'
    end
    it "calls handle_multiple_keywords otherwise" do
      expect(@lnf_obj).to receive :handle_multiple_keywords
      @lnf_obj.get_image_from_set(Set.new(%w(Programmer Engineer)), '')
    end
  end

  describe "handle_multiple_keywords" do
    it "returns stock image if it's the same for all words" do
      expect(@lnf_obj.handle_multiple_keywords(Set.new(%w(Programmer Developer)), '')).to eq 'Computer.jpg'
    end

    it "returns word that appears the most in the title" do
      expect(@lnf_obj.handle_multiple_keywords(Set.new(%w(Nurse Manager Assistant)),
                                               'Registered Nurse -Assistant Nurse Manager')).to eq 'Nurse.jpg'
    end

    it "removes less descriptive words when image is not initially found" do
      expect(@lnf_obj.handle_multiple_keywords(Set.new(%w(Assistant Cook)), '')).to eq 'Chef.jpg'
    end

    it "returns the word that appears first if the above strategies failed" do
      expect(@lnf_obj.handle_multiple_keywords(Set.new(%w(Sales Executive)), 'Sales Executive')).to eq 'Business.jpg'
      expect(@lnf_obj.handle_multiple_keywords(Set.new(%w(Sales Executive)), 'Executive Sales')).to eq 'Manager.jpg'
    end
  end

  describe "get_most_frequent_word" do
    it "returns word that appears most frequently" do
      expect(@lnf_obj.get_most_frequent_word(Set.new(%w(Nurse Manager Assistant)),
                                               'Registered Nurse -Assistant Nurse Manager')).to eq 'Nurse'
    end
    it "returns nil if no word appears most frequently" do
      expect(@lnf_obj.get_most_frequent_word(Set.new(%w(Sales Executive)), 'Sales Executive')).to be_nil
      expect(@lnf_obj.get_most_frequent_word(Set.new(%w(Sales Executive)), '')).to be_nil
    end
  end

  describe "delete_expired_jobs" do
    before :all do
      feed_listing = create :listing, ref_id: 64361742, title: 'Substitute Child Development Program Director'
      other_listing = create :listing, ref_id: 6, title: 'Substitute Child Development Program Director'
      File.open('job.xml', 'w') do |file|
        file.write("<job><referencenumber><![CDATA[64361742]]></referencenumber></job>")
      end
      @lnf_obj.ref_id_xpath = Nokogiri::XML(open('job.xml')).xpath('//referencenumber')
      @lnf_obj.delete_expired_jobs
      File.delete('job.xml')
    end

    it "deletes job if ref_id is in DB but not the feed" do
      expect(Listing.find_by_ref_id(6).status).to eq 'expired'
    end

    it "does not delete job if ref_id is in feed" do
      expect(Listing.find_by_ref_id(64361742).status).to eq 'active'
    end
  end

  def set_site_xpaths(city, state)
    File.open('job.xml', 'w') do |file|
      file.write("<job><city><![CDATA[" << city << "]]></city><state><![CDATA[" << state << "]]></state></job>")
    end
    doc = Nokogiri::XML(open('job.xml'))
    @lnf_obj.city_xpath = doc.xpath('//city')
    @lnf_obj.state_xpath = doc.xpath('//state')
    File.delete('job.xml')
  end

  describe "get_site_id" do
    before :all do
      @site = create :site, org_type: 'city', name: 'Franklin'
      @site.contacts.create(FactoryGirl.attributes_for(:contact, address: '9900 S. 57th Street',
        city: 'Franklin', state: 'WI', zip: '53132'))
    end

    it "returns site if its contact is in the same the state" do
      set_site_xpaths('Franklin', 'WI')
      expect(Site.find(@lnf_obj.get_site_id(0)).name).to eq "Franklin"
    end

    it "creates a new site if its contact is in a different state " do
      set_site_xpaths('Franklin', 'NJ')
      expect(Site.find(@lnf_obj.get_site_id(0)).name).to eq "Franklin, NJ"
    end

    it "creates a new site if it was not found" do
      set_site_xpaths('Madison', 'WI')
      expect(Site.find(@lnf_obj.get_site_id(0)).name).to eq "Madison"
    end
  end
end