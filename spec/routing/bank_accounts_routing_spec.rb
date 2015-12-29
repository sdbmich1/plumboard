require "spec_helper"

describe BankAccountsController do
  describe 'bank_accounts routes', base: true do
    it_should_behave_like 'an index route', true, 'index', 'bank_accounts'
    it_should_behave_like 'a get route', true, 'new', 'bank_accounts'
    it_should_behave_like 'a get item route', true, 'show', 'bank_accounts'
    it_should_behave_like 'a get item route', false, 'edit', 'bank_accounts'
    it_should_behave_like 'a put route', false, 'update', 'bank_accounts'
    it_should_behave_like 'a post route', true, 'create', 'bank_accounts'
    it_should_behave_like 'a delete route', true, 'destroy', 'bank_accounts'
    it_should_behave_like 'a subdomain route', true, 'bank_accounts/autocomplete_user_first_name', 'autocomplete_user_first_name','bank_accounts'
  end
end

