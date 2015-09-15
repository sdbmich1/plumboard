require 'spec_helper'

shared_examples 'seller_url_pages' do |follow_flg, map_flg|
  describe 'view urls' do
    it 'renders seller page for user' do
      visit seller.local_user_path
      page.should have_content seller.name
      page.should have_content seller.description
      page.should have_selector('#follow-btn', visible: follow_flg)
      page.should have_selector('#map_icon', visible: map_flg)
      expect(Listing.count).not_to eq 0
    end
  end
end	

shared_examples 'site_url_pages' do |name, rte, type|
  describe "site url" do
    before(:each) do
      @loc = create :site, name: name, site_type_code: type
      add_pixis seller, @loc
    end
     
    it "does show site page" do
      visit "/#{rte}/#{@loc.url}"
      page.should have_content @loc.name
      page.should have_content 'Acoustic Guitar'
      page.should have_content 'Bass Guitar'
    end
     
    it "does not show site page" do
      visit "/#{rte}/xxxx"
      page.should_not have_content @loc.name
      page.should_not have_content listing.nice_title(false)
    end
  end
end	

shared_examples 'searches controller index' do |klass, var|
  before :each do
    @mock_klass = mock(klass.downcase.pluralize)
    klass.constantize.stub!(:search).and_return(@mock_klass)
    controller.stub!(:current_user).and_return(@mock_klass)
    controller.stub_chain(:query, :page).and_return(:success)
  end

  def do_get
    xhr :get, :index, search: 'test'
  end

  it "should load the requested user" do
    klass.constantize.stub(:search).with('test').and_return(@mock_klass)
    do_get
  end

  it "should assign @mock_klass" do
    do_get
    assigns(var.to_sym).should == @mock_klass
  end

  it "index action should render nothing" do
    do_get
    controller.stub!(:render)
  end
end
