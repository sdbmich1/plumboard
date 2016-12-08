require "spec_helper"

describe PromoCodeUsersController do
  describe 'promo_codes routes', base: true do
    it_should_behave_like 'an index route', true, 'index', 'promo_code_users'
    it_should_behave_like 'a get route', false, 'new', 'promo_code_users'
    it_should_behave_like 'a get item route', false, 'show', 'promo_code_users'
    it_should_behave_like 'a get item route', false, 'edit', 'promo_code_users'
    it_should_behave_like 'a put route', true, 'update', 'promo_code_users'
    it_should_behave_like 'a post route', true, 'create', 'promo_code_users'
    it_should_behave_like 'a delete route', false, 'destroy', 'promo_code_users'
  end
end
