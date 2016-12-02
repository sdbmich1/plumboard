require "spec_helper"

  describe 'search routes', base: true do
    it_should_behave_like 'an index route', true, 'index', 'user_searches'
    it_should_behave_like 'a get route', false, 'new', 'user_searches'
    it_should_behave_like 'a get item route', false, 'show', 'user_searches'
    it_should_behave_like 'a get item route', false, 'edit', 'user_searches'
    it_should_behave_like 'a put route', false, 'update', 'user_searches'
    it_should_behave_like 'a post route', false, 'create', 'user_searches'
    it_should_behave_like 'a delete route', false, 'destroy', 'user_searches'
    it_should_behave_like 'a subdomain route', true, 'user_searches/autocomplete_user_first_name', 'autocomplete_user_first_name','user_searches'
  end
