require "spec_helper"

  describe 'search routes', base: true do
    it_should_behave_like 'an index route', true, 'index', 'promo_code_searches'
    it_should_behave_like 'a get route', false, 'new', 'promo_code_searches'
    it_should_behave_like 'a get item route', false, 'show', 'promo_code_searches'
    it_should_behave_like 'a get item route', false, 'edit', 'promo_code_searches'
    it_should_behave_like 'a put route', false, 'update', 'promo_code_searches'
    it_should_behave_like 'a post route', false, 'create', 'promo_code_searches'
    it_should_behave_like 'a delete route', false, 'destroy', 'promo_code_searches'
  end
