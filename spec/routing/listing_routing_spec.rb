require "spec_helper"

describe ListingsController do
  describe 'listings routes', base: true do
    %w(seller seller_wanted invoiced).each do |rte|
      it_should_behave_like 'a get route', true, rte, 'listings'
    end
    it_should_behave_like 'an index route', true, 'index', 'listings'
    it_should_behave_like 'a get item route', true, 'show', 'listings'
    it_should_behave_like 'a get item route', false, 'edit', 'listings'
    it_should_behave_like 'a put route', true, 'update', 'listings'
    it_should_behave_like 'a put route', true, 'repost', 'listings'
    it_should_behave_like 'a post route', false, 'create', 'listings'
    it_should_behave_like 'a delete route', false, 'destroy', 'listings'
    it_should_behave_like 'a custom route', true, 'careers', 'career', 'listings'
  end
    
  describe 'url routes', base: true do
    %w(mbr biz pub edu loc).each do |rte|
      it_should_behave_like 'a url route', true, rte, 'listings'
    end
  end
end

