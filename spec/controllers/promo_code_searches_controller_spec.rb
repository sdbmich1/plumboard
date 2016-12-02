require 'login_user_spec'

describe PromoCodeSearchesController do
  include LoginTestUser

  before(:each) do
    log_in_test_user
  end

  def load_data 
    @user = double("User", params: {loc: 1, zip: '94111'}, home_zip: true, add_points: nil, comments: nil)
    allow(AppFacade).to receive_message_chain(:set_region, :home_zip).and_return(@user)
    allow(controller).to receive(:current_user).and_return(@user)
    allow(controller).to receive(:get_zip).and_return(:success)
    allow(@user).to receive_message_chain(:home_zip, :to_region).and_return( :success )
  end

  describe 'GET /index' do
    before :each do
      load_data
    end
    context 'load promos' do
      it_behaves_like 'searches controller index', 'PromoCode', 'promos'
    end
  end
end
