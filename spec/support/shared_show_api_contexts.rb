require 'spec_helper'

def set_show_data klass, method
  @listing = stub_model(klass.constantize)
  allow(klass.constantize).to receive(method.to_sym).and_return(@listing)
end

def do_get_url rte, status
  if status
    xhr :get, rte.to_sym, :id => '1'
  else
    get rte.to_sym, :id => "1"
  end
end

shared_context "a show method" do |klass, method, rte, status, renderFlg, var|
  describe 'update methods' do
    before :each do
      set_show_data klass, method
    end

    it "shows the requested listing" do
      do_get_url(rte, status)
    end

    it "loads the requested listing" do
      allow(klass.constantize).to receive(method.to_sym).with("1").and_return(@listing)
      do_get_url(rte, status)
    end

    it "assigns var" do
      do_get_url(rte, status)
      expect(assigns(var.to_sym)).not_to be_nil
    end

    it "renders template" do
      do_get_url(rte, status)
      if renderFlg
        expect(response).to render_template rte.to_sym
      else
        allow(controller).to receive(:render)
      end
    end

    it "responds successfully" do
      expect(response).to be_success
    end

    it "responds to JSON" do
      get :show, :id => '1', :format => :json
      expect(response).to be_success
    end
  end
end
