require 'spec_helper'

def set_delete_data klass, method, rte, tname, xhr=false
  @listing = stub_model(klass.constantize)
  allow(klass.constantize).to receive(method.to_sym).and_return(@listing)
  allow(@listing).to receive(tname.to_sym).and_return(xhr)
end

def do_delete_url rte
  delete rte.to_sym, :id => "1"
end

def mock_klass(klass, stubs={})
  (@mock_klass ||= mock_model(klass, stubs).as_null_object).tap do |obj|
    obj.stub(stubs) unless stubs.empty?
  end
end

shared_context "a model delete assignment" do |klass, method, rte, tname, status, var|
  describe 'delete methods' do
    before :each do
      set_delete_data klass, method, rte, tname, status
    end

    it "should load the requested listing" do
      allow(klass.constantize).to receive(:method) { @listing }
      do_delete_url(rte)
    end

    it "should delete the requested listing" do
      allow(klass.constantize).to receive(method.to_sym).with("1") { mock_klass(klass) }
      expect(mock_klass(klass)).to receive(tname.to_sym).and_return(:success)
      do_delete_url(rte)
    end

    it "should assign var" do
      do_delete_url(rte)
      expect(assigns(var.to_sym)).not_to be_nil
    end

    it "changes model count" do
      val = status ? -1 : 0
      lambda do
        do_delete_url rte
        is_expected.to change(klass.constantize, :count).by(val)
      end
    end
  end
end

shared_context "a delete redirected page" do |klass, method, rte, tname, status|
  it "redirects the page" do
    set_data klass, method, rte, tname, status
    do_delete_url(rte)
    expect(response.status).not_to eq(0)
    # response.should be_redirect
  end
end

shared_context "a failed delete template" do |klass, method, rte, tname, xhr|
  it "action should render template" do
    set_data klass, method, rte, tname, xhr
    do_delete_url(rte)
    expect(response).to render_template tname.to_sym
  end
end
