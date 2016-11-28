require "spec_helper"

describe PromoCodesController do
  describe 'promo_codes routes', base: true do
    it_should_behave_like 'an index route', true, 'index', 'promo_codes'
    it_should_behave_like 'a get route', true, 'new', 'promo_codes'
    it_should_behave_like 'a get item route', true, 'show', 'promo_codes'
    it_should_behave_like 'a get item route', true, 'edit', 'promo_codes'
    it_should_behave_like 'a put route', true, 'update', 'promo_codes'
    it_should_behave_like 'a post route', true, 'create', 'promo_codes'
    it_should_behave_like 'a delete route', true, 'destroy', 'promo_codes'
  end
end
