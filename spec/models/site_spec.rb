require 'spec_helper'

describe Site do
  before(:each) do
    @site = FactoryGirl.create(:site) 
  end
   
  subject { @site } 

  context "should have an user method" do
    it { should respond_to(:users) }
  end

  context "should have an site_users method" do
    it { should respond_to(:site_users) }
  end

  context "should have an site_listings method" do
    it { should respond_to(:site_listings) }
  end

  describe "should include active sites" do
    it { Site.active.should_not be_nil }
  end

  describe "should not include inactive sites" do
    site = Site.create(:name=>'Item', :status=>'inactive')
    it { Site.active.should_not include (site) } 
  end

  describe "when name is empty" do
    before { @site.name = "" }
    it { should_not be_valid }
  end

  describe 'pictures' do
    before(:each) do
      @sr = @site.pictures.create FactoryGirl.attributes_for(:picture)
    end

    it "should have a pictures method" do
      @site.should respond_to(:pictures)
    end
				            
    it "has many pictures" do 
      @site.pictures.should include(@sr)
    end

    it "should destroy associated pictures" do
      @site.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
     end  
   end  

  describe 'contacts' do
    before(:each) do
      @sr = @site.contacts.create FactoryGirl.attributes_for(:contact) 
    end

    context "should have a contacts method" do
      it { should respond_to(:contacts) }
    end

    it "has many contacts" do 
      @site.contacts.should include(@sr)
    end

    it "should destroy associated contacts" do
      @site.destroy
      [@sr].each do |s|
         Contact.find_by_id(s.id).should be_nil
       end
     end  
   end  
end
