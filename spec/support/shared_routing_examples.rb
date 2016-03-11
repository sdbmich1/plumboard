require 'spec_helper'

shared_examples 'a post method route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'to' : 'not_to'
    it { expect(post("/#{cntr}/#{method}")).send(action, route_to("#{cntr}##{method}")) }
  end
end

shared_examples 'a post route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'to' : 'not_to'
    it { expect(post("/#{cntr}")).send(action, route_to("#{cntr}##{method}")) }
  end
end

shared_examples 'a get route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'to' : 'not_to'
    it { expect(get("/#{cntr}/#{method}")).send(action, route_to("#{cntr}##{method}")) }
  end
end

shared_examples 'an index route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'to' : 'not_to'
    it { expect(get("/#{cntr}")).send(action, route_to("#{cntr}##{method}")) }
  end
end

shared_examples 'a get item route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'to' : 'not_to'
    rte = method == 'show' ? "/#{cntr}/1" : "/#{cntr}/1/#{method}"  
    it { expect(get(rte)).send(action, route_to("#{cntr}##{method}", :id => "1")) }
  end
end

shared_examples 'a delete route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'to' : 'not_to'
    it { expect(delete("/#{cntr}/1")).send(action, route_to("#{cntr}##{method}", :id => "1")) }
  end
end

shared_examples 'a put route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'to' : 'not_to'
    rte = method == 'update' ? "/#{cntr}/1" : "/#{cntr}/1/#{method}"
    it { expect(put(rte)).send(action, route_to("#{cntr}##{method}", :id => "1")) }
  end
end

shared_examples 'a url route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'to' : 'not_to'
    it { expect(:get => "/#{method}/test").send(action, route_to(:controller=>cntr, :action=>method, :url =>"test")) }
  end
end

shared_examples 'a custom route' do |notFlg, rte, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'to' : 'not_to'
    it { expect(:get => "/#{rte}").send(action, route_to(:controller=>cntr, :action=>method))}
  end
end

shared_examples 'a subdomain route' do |notFlg, rte, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'to' : 'not_to'
    it { expect(:get => "#{rte}").send(action, route_to(:controller=>cntr, :action=>method))}
  end
end
