require "spec_helper"

  describe 'search routes', base: true do
    it_should_behave_like 'an index route', true, 'index', 'searches'
    # it_should_behave_like 'a post route', true, 'locate', 'searches'
    it_should_behave_like 'a get route', false, 'new', 'searches'
    it_should_behave_like 'a get item route', false, 'show', 'searches'
    it_should_behave_like 'a get item route', false, 'edit', 'searches'
    it_should_behave_like 'a put route', false, 'update', 'searches'
    it_should_behave_like 'a post route', false, 'create', 'searches'
    it_should_behave_like 'a delete route', false, 'destroy', 'searches'
    it_should_behave_like 'a subdomain route', true, 'searches/autocomplete_listing_title', 'autocomplete_listing_title','searches'

    it 'routes to #locate' do
      post('/searches/locate').should route_to('searches#locate')
    end
  end
