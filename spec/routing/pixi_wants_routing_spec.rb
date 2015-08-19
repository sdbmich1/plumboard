require "spec_helper"

describe PixiWantsController do
  describe 'routing' do
    it 'routes to #create' do
      post('/pixi_wants').should route_to('pixi_wants#create')
    end

    it 'routes to #index' do
      get('/pixi_wants').should_not route_to('pixi_wants#index')
    end
  end
end

