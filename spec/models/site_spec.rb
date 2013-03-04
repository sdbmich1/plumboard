require 'spec_helper'

describe Site do
  before(:each) do
    @site = FactoryGirl.create(:site) 
  end
   
  subject { @site } 

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:org_type) }
  it { should respond_to(:status) }
  it { should respond_to(:institution_id) }

  it { should respond_to(:users) }
  it { should respond_to(:site_users) }
  it { should respond_to(:site_listings) }
  it { should respond_to(:listings) }
  it { should respond_to(:temp_listings) }

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
