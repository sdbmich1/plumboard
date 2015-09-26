require "spec_helper"

describe ShopLocalsController do
  describe 'shop_locals routes', base: true do
    it_should_behave_like 'an index route', true, 'index', 'shop_locals'
    it_should_behave_like 'a get item route', false, 'new', 'shop_locals'
    it_should_behave_like 'a get item route', false, 'show', 'shop_locals'
    it_should_behave_like 'a get item route', false, 'edit', 'shop_locals'
    it_should_behave_like 'a put route', false, 'update', 'shop_locals'
    it_should_behave_like 'a post route', false, 'create', 'shop_locals'
    it_should_behave_like 'a delete route', false, 'destroy', 'shop_locals'
    it_should_behave_like 'a subdomain route', true, 'http://shoplocal.pixiboard.com', 'index', 'shop_locals'
    it_should_behave_like 'a subdomain route', false, 'http://game.pixiboard.com', 'index', 'shop_locals'
  end
end
