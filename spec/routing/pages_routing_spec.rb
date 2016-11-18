require "spec_helper"

describe PagesController do
  describe 'custom routes', base: true do
    %w(location_name location_id).each do |rte|
      it_should_behave_like 'a get route', true, rte, 'pages'
    end
    %w(giveaway help about privacy terms howitworks).each do |rte|
      it_should_behave_like 'a custom route', true, rte, rte, 'pages'
    end
  end
end

