require 'spec_helper'

def set_show_data klass, method
  @listing = stub_model(klass.constantize)
  klass.constantize.stub(method.to_sym).and_return(@listing)
end

def do_get_url rte, status
  if status
    xhr :get, rte.to_sym, :id => '1'
  else
    get rte.to_sym, :id => "1"
  end
end

shared_context "a show method" do |klass, method, rte, status, renderFlg|
  describe 'update methods' do
    before :each do
      set_show_data klass, method
    end

    it "shows the requested listing" do
      do_get_url(rte, status)
    end

    it "loads the requested listing" do
      klass.constantize.stub(method.to_sym).with("1").and_return(@listing)
      do_get_url(rte, status)
    end

    it "assigns @listing" do
      do_get_url(rte, status)
      assigns(:listing).should_not be_nil
    end

    it "renders template" do
      do_get_url(rte, status)
      if renderFlg
        response.should render_template rte.to_sym
      else
        controller.stub!(:render)
      end
    end

    it "responds successfully" do
      response.should be_success
    end

    it "responds to JSON" do
      get :show, :id => '1', :format => :json
      expect(response).to be_success
    end
  end
end
