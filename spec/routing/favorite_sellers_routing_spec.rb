require "spec_helper"

describe "routes for FavoriteSellers" do
  it_should_behave_like 'an index route', true, 'index', 'favorite_sellers'
  it_should_behave_like 'a get item route', false, 'new', 'favorite_sellers'
  it_should_behave_like 'a get item route', false, 'show', 'favorite_sellers'
  it_should_behave_like 'a get item route', false, 'edit', 'favorite_sellers'
  it_should_behave_like 'a put route', true, 'update', 'favorite_sellers'
  it_should_behave_like 'a post route', true, 'create', 'favorite_sellers'
  it_should_behave_like 'a delete route', false, 'destroy', 'favorite_sellers'
end

