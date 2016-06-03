require 'spec_helper'

describe Stripe::WebhooksController do
  describe 'webhooks routes', base: true do
    it_should_behave_like 'an index route', false, 'index', 'stripe/webhooks'
    it_should_behave_like 'a get item route', false, 'new', 'stripe/webhooks'
    it_should_behave_like 'a get item route', false, 'show', 'stripe/webhooks'
    it_should_behave_like 'a get item route', false, 'edit', 'stripe/webhooks'
    it_should_behave_like 'a put route', false, 'update', 'stripe/webhooks'
    it_should_behave_like 'a post route', true, 'create', 'stripe/webhooks'
    it_should_behave_like 'a delete route', false, 'destroy', 'stripe/webhooks'
  end
end
