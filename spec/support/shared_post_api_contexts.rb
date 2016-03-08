require 'spec_helper'

def set_create_data klass, method, rte, tname, xhr=false
  @listing = stub_model(klass.constantize)
  allow(klass.constantize).to receive(method.to_sym).and_return(@listing)
  allow(@listing).to receive(tname.to_sym).and_return(xhr)
end

def do_post_url rte, flg
  if flg
    xhr :post, rte.to_sym, id: '1'
  else
    post rte.to_sym, :id => "1"
  end
end

def mock_klass(klass, stubs={})
  (@mock_klass ||= mock_model(klass, stubs).as_null_object).tap do |obj|
    allow(obj).to receive(stubs) unless stubs.empty?
  end
end

shared_context "a model create assignment" do |klass, method, rte, tname, status, var|
  describe 'create methods' do
    before :each do
      set_create_data klass, method, rte, tname, status
    end

    it "should load the requested listing" do
      allow(klass.constantize).to receive(:method) { @listing }
      do_post_url(rte, status)
    end

    it "should create the requested listing" do
      allow(klass.constantize).to receive(method.to_sym).with("1") { mock_klass(klass) }
      do_post_url(rte, status)
    end

    it "should assign var" do
      allow(klass.constantize).to receive(method.to_sym).with({'user_id'=>'test', 'data'=>'test' }) { mock_klass(klass, tname.to_sym => status) }
      do_post_url(rte, status)
      expect(assigns(var.to_sym)).not_to be_nil
    end

    it "changes model count" do
      val = status ? 1 : 0
      lambda do
        do_post_url rte
        is_expected.to change(klass.constantize, :count).by(val)
      end
    end
  end
end

shared_context "a post redirected page" do |klass, method, rte, tname, status|
  it "redirects the page" do
    set_data klass, method, rte, tname, status
    do_post_url(rte, status)
    expect(response.status).to eq(302)
    # response.should be_redirect
  end
end

shared_context "a failed create template" do |klass, method, rte, tname, xhr|
  it "action should render template" do
    set_data klass, method, rte, tname, xhr
    do_post_url(rte, status)
    expect(response).to render_template tname.to_sym
  end
end
