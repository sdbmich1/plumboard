require "spec_helper"

describe PixiWantsController do
  describe 'routing' do
    it 'routes to #create' do
      expect(post('/pixi_wants')).to route_to('pixi_wants#create')
    end

    it 'routes to #buy_now' do
      expect(post('/pixi_wants/buy_now')).to route_to('pixi_wants#buy_now')
    end

    it 'does not route to #index' do
      expect(get('/pixi_wants')).not_to route_to('pixi_wants#index')
    end
  end
end

