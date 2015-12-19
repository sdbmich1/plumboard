require "spec_helper"

describe CardAccountsController do
  describe 'card_accounts routes', base: true do
    it_should_behave_like 'an index route', true, 'index', 'card_accounts'
    it_should_behave_like 'a get route', true, 'new', 'card_accounts'
    it_should_behave_like 'a get item route', true, 'show', 'card_accounts'
    it_should_behave_like 'a get item route', false, 'edit', 'card_accounts'
    it_should_behave_like 'a put route', false, 'update', 'card_accounts'
    it_should_behave_like 'a post route', true, 'create', 'card_accounts'
    it_should_behave_like 'a delete route', true, 'destroy', 'card_accounts'
  end
end

