require 'spec_helper'

describe Organization do
  before(:each) do
    @organization = FactoryGirl.create(:organization) 
  end

  it "should have an user method" do
    @organization.should respond_to(:users)
  end

  it "should have an org_users method" do
    @organization.should respond_to(:org_users) 
  end

  it "should have an org_listings method" do
    @organization.should respond_to(:org_listings)
  end

  describe "when name is empty" do
    before { @organization.name = "" }
    it { should_not be_valid }
  end

  describe "should include active organizations" do
    org = Organization.create(:name=>'Item', :status=>'active')
    it { Organization.active.should include (org) } 
  end

  describe "should not include inactive organizations" do
    org = Organization.create(:name=>'Item', :status=>'inactive')
    it { Organization.active.should_not include (org) } 
  end

  describe 'pictures' do
    before(:each) do
      @sr = @organization.pictures.create FactoryGirl.attributes_for(:picture)
    end

    it "should have a pictures method" do
      @organization.should respond_to(:pictures)
    end
				            
    it "has many pictures" do 
      @organization.pictures.should include(@sr)
    end

    it "should destroy associated pictures" do
      @organization.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
     end  
   end  
end
