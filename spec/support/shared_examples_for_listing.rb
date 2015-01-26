require 'spec_helper'

shared_examples "an Listing class" do |model|

  describe 'attributes' do
    describe '.fields' do
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
      it { should respond_to(:job_type_code) }
      it { should respond_to(:event_type_code) }
      it { should respond_to(:explanation) }
      it { should respond_to(:repost_flg) }
      it { should respond_to(:quantity) }
      it { should respond_to(:condition_type_code) }
      it { should respond_to(:color) }
      it { should respond_to(:other_id) }
      it { should respond_to(:mileage) }
      it { should respond_to(:item_type) }
      it { should respond_to(:size) }
    end
  end
  
end
