require 'spec_helper'

def set_create_data klass, method, rte, tname, xhr=false
  @listing = stub_model(klass.constantize)
  klass.constantize.stub(method.to_sym).and_return(@listing)
  @listing.stub!(tname.to_sym).and_return(xhr)
end

def do_post_url rte
  post rte.to_sym, :id => "1"
end

def mock_klass(klass, stubs={})
  (@mock_klass ||= mock_model(klass, stubs).as_null_object).tap do |obj|
    obj.stub(stubs) unless stubs.empty?
  end
end

shared_context "a model create assignment" do |klass, method, rte, tname, status, var|
  describe 'create methods' do
    before :each do
      set_create_data klass, method, rte, tname, status
    end

    it "should load the requested listing" do
      klass.constantize.stub(:method) { @listing }
      do_post_url(rte)
    end

    it "should create the requested listing" do
      klass.constantize.stub(method.to_sym).with("1") { mock_klass(klass) }
      do_post_url(rte)
    end

    it "should assign var" do
      klass.constantize.stub(method.to_sym).with({'user_id'=>'test', 'data'=>'test' }) { mock_klass(klass, tname.to_sym => status) }
      do_post_url(rte)
      assigns(var.to_sym).should_not be_nil
    end

    it "changes model count" do
      val = status ? 1 : 0
      lambda do
        do_post_url rte
        should change(klass.constantize, :count).by(val)
      end
    end
  end
end

shared_context "a post redirected page" do |klass, method, rte, tname, status|
  it "redirects the page" do
    set_data klass, method, rte, tname, status
    do_post_url(rte)
    expect(response.status).to eq(302)
    # response.should be_redirect
  end
end

shared_context "a failed create template" do |klass, method, rte, tname, xhr|
  it "action should render template" do
    set_data klass, method, rte, tname, xhr
    do_post_url(rte)
    response.should render_template tname.to_sym
  end
end
