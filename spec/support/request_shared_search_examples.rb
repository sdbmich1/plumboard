require 'spec_helper'

shared_examples 'seller_url_pages' do |follow_flg, map_flg|
  describe 'view urls' do
    it 'renders seller page for user' do
      visit seller.local_user_path
      expect(page).to have_content seller.name
      expect(page).to have_content seller.description
      expect(page).to have_selector('#follow-btn', visible: follow_flg)
      expect(page).to have_selector('#map_icon', visible: map_flg)
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
      expect(page).to have_content @loc.name
      expect(page).to have_content 'Acoustic Guitar'
      expect(page).to have_content 'Bass Guitar'
    end
     
    it "does not show site page" do
      visit "/#{rte}/xxxx"
      expect(page).not_to have_content @loc.name
      expect(page).not_to have_content listing.nice_title(false)
    end
  end
end	

shared_examples 'searches controller index' do |klass, var|
  before :each do
    @mock_klass = double(klass.downcase.pluralize)
    allow(klass.constantize).to receive(:search).and_return(@mock_klass)
    allow(controller).to receive(:current_user).and_return(@mock_klass)
    allow(controller).to receive_message_chain(:query, :page).and_return(:success)
  end

  def do_get
    xhr :get, :index, search: 'test'
  end

  it "should load the requested user" do
    allow(klass.constantize).to receive(:search).with('test').and_return(@mock_klass)
    do_get
  end

  it "should assign @mock_klass" do
    do_get
    expect(assigns(var.to_sym)).to eq(@mock_klass)
  end

  it "index action should render nothing" do
    do_get
    allow(controller).to receive(:render)
  end
end
