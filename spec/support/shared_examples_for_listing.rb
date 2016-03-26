require 'spec_helper'

shared_examples "an Listing class" do |model|

  describe 'attributes' do
    describe '.fields' do
      it { is_expected.to respond_to(:title) }
      it { is_expected.to respond_to(:description) }
      it { is_expected.to respond_to(:site_id) }
      it { is_expected.to respond_to(:seller_id) }
      it { is_expected.to respond_to(:alias_name) }
      it { is_expected.to respond_to(:transaction_id) }
      it { is_expected.to respond_to(:show_alias_flg) }
      it { is_expected.to respond_to(:status) }
      it { is_expected.to respond_to(:price) }
      it { is_expected.to respond_to(:start_date) }
      it { is_expected.to respond_to(:end_date) }
      it { is_expected.to respond_to(:buyer_id) }
      it { is_expected.to respond_to(:show_phone_flg) }
      it { is_expected.to respond_to(:category_id) }
      it { is_expected.to respond_to(:pixi_id) }
      it { is_expected.to respond_to(:parent_pixi_id) }
      it { is_expected.to respond_to(:post_ip) }
      it { is_expected.to respond_to(:event_start_date) }
      it { is_expected.to respond_to(:event_end_date) }
      it { is_expected.to respond_to(:compensation) }
      it { is_expected.to respond_to(:lng) }
      it { is_expected.to respond_to(:lat) }
      it { is_expected.to respond_to(:event_start_time) }
      it { is_expected.to respond_to(:event_end_time) }
      it { is_expected.to respond_to(:year_built) }
      it { is_expected.to respond_to(:pixan_id) }
      it { is_expected.to respond_to(:job_type_code) }
      it { is_expected.to respond_to(:event_type_code) }
      it { is_expected.to respond_to(:explanation) }
      it { is_expected.to respond_to(:repost_flg) }
      it { is_expected.to respond_to(:quantity) }
      it { is_expected.to respond_to(:condition_type_code) }
      it { is_expected.to respond_to(:color) }
      it { is_expected.to respond_to(:other_id) }
      it { is_expected.to respond_to(:mileage) }
      it { is_expected.to respond_to(:item_type) }
      it { is_expected.to respond_to(:size) }
    end
  end
  
end
