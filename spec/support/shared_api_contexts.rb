require 'spec_helper'

def set_data klass, method, rte, tname, xhr=false
  @listings = stub_model(klass.constantize)
  klass.constantize.stub_chain(method.to_sym).and_return(@listings)
  allow(@listings).to receive(tname.to_sym).and_return( @listings ) if tname
  xhr ? set_xhr_rte(tname, rte) : do_get_list(rte)
end

def set_xhr_rte tname, rte
  tname.blank? ? do_other_xhr_get(rte) : do_xhr_get(rte)
end
              
def do_xhr_get rte
  xhr :get, rte.to_sym, id: '1'
end
              
def do_other_xhr_get rte
  xhr :get, rte.to_sym, search: '1'
end

def do_get_list rte
  get rte.to_sym, use_route: "/#{rte}", :params => {url: 'test'}
end

shared_context "a load data request" do |klass, method, rte, tname, xhr, var|
  describe 'load data' do
    before :each do
      set_data klass, method, rte, tname, xhr
    end

    it "loads the requested data" do
      allow(klass.constantize).to receive(method.to_sym).with('test').and_return(@listings)
    end

    it "should assign var" do
      expect(assigns(var.to_sym)).not_to be_nil # == @listings
    end

    it "action should render get template" do
      expect(response).to render_template rte.to_sym if tname
    end
  end
end

shared_context "a JSON request" do |klass, method, rte, tname, xhr|
  it "responds to JSON" do
    set_data klass, method, rte, tname, xhr
    get rte.to_sym, :loc =>'1', format: :json
    expect(response).to be_success
  end
end

shared_context "a CSV request" do |klass, method, rte, tname, xhr|
  it "responds to CSV" do 
    set_data klass, method, rte, tname, xhr
    get rte.to_sym, :status => 'active', :format => 'csv'
    expect(response).to be_success
  end
end
