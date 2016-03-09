require 'spec_helper'

def set_update_data klass, method, rte, tname, xhr=false
  @listing = stub_model(klass.constantize)
  allow(klass.constantize).to receive(method.to_sym).and_return(@listing)
  allow(@listing).to receive(tname.to_sym).and_return(xhr)
end

def do_put_url rte
  put rte.to_sym, :id => "1"
end

def mock_klass(klass, stubs={})
  (@mock_klass ||= mock_model(klass, stubs).as_null_object).tap do |obj|
    allow(obj).to receive(stubs) unless stubs.empty?
  end
end

shared_context "a model update assignment" do |klass, method, rte, tname, status, var|
  describe 'update methods' do
    before :each do
      set_update_data klass, method, rte, tname, status
    end

    it "should load the requested listing" do
      allow(klass.constantize).to receive(:method) { @listing }
      do_put_url(rte)
    end

    it "should update the requested listing" do
      allow(klass.constantize).to receive(method.to_sym).with("1") { mock_klass(klass) }
      expect(mock_klass(klass)).to receive(tname.to_sym).and_return(:success)
      do_put_url(rte)
    end

    it "should assign var" do
      allow(klass.constantize).to receive(method.to_sym) { mock_klass(klass, tname.to_sym => status) }
      do_put_url(rte)
      expect(assigns(var.to_sym)).not_to be_nil
    end
  end
end

shared_context "a redirected page" do |klass, method, rte, tname, status|
  it "redirects the page" do
    set_data klass, method, rte, tname, status
    do_put_url(rte)
    expect(response.status).to eq(302)
    # response.should be_redirect
  end
end

shared_context "a failed update template" do |klass, method, rte, tname, xhr|
  it "action should render template" do
    set_data klass, method, rte, tname, xhr
    do_put_url(rte)
    expect(response).to render_template tname.to_sym
  end
end
