require 'spec_helper'

describe OldListing do
  before(:each) do
    @user = FactoryGirl.create(:pixi_user) 
    @category = FactoryGirl.create(:category, pixi_type: 'premium') 
    @listing = FactoryGirl.build(:old_listing, seller_id: @user.id) 
  end

  subject { @listing }

  it { should respond_to(:title) }
  it { should respond_to(:description) }
  it { should respond_to(:site_id) }
  it { should respond_to(:seller_id) }
  it { should respond_to(:alias_name) }
  it { should respond_to(:transaction_id) }
  it { should respond_to(:show_alias_flg) }
  it { should respond_to(:status) }
  it { should respond_to(:price) }
  it { should respond_to(:start_date) }
  it { should respond_to(:end_date) }
  it { should respond_to(:buyer_id) }
  it { should respond_to(:show_phone_flg) }
  it { should respond_to(:category_id) }
  it { should respond_to(:pixi_id) }
  it { should respond_to(:parent_pixi_id) }
  it { should respond_to(:post_ip) }
  it { should respond_to(:event_start_date) }
  it { should respond_to(:event_end_date) }
  it { should respond_to(:compensation) }
  it { should respond_to(:lng) }
  it { should respond_to(:lat) }
  it { should respond_to(:event_start_time) }
  it { should respond_to(:event_end_time) }
  it { should respond_to(:year_built) }
  it { should respond_to(:pixan_id) }

  it { should respond_to(:user) }
  it { should respond_to(:pictures) }
end
