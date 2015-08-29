require 'spec_helper'

shared_examples 'a post route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'should' : 'should_not'
    it { post("/#{cntr}/#{method}").send(action, route_to("#{cntr}##{method}")) }
  end
end

shared_examples 'a get route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'should' : 'should_not'
    it { get("/#{cntr}/#{method}").send(action, route_to("#{cntr}##{method}")) }
  end
end

shared_examples 'an index route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'should' : 'should_not'
    it { get("/#{cntr}").send(action, route_to("#{cntr}##{method}")) }
  end
end

shared_examples 'a get item route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'should' : 'should_not'
    rte = method == 'show' ? "/#{cntr}/1" : "/#{cntr}/1/#{method}"  
    it { get(rte).send(action, route_to("#{cntr}##{method}", :id => "1")) }
  end
end

shared_examples 'a delete route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'should' : 'should_not'
    it { delete("/#{cntr}/1").send(action, route_to("#{cntr}##{method}", :id => "1")) }
  end
end

shared_examples 'a put route' do |notFlg, method, cntr|
  describe 'route tests' do
    action = notFlg ? 'should' : 'should_not'
    rte = method == 'update' ? "/#{cntr}/1" : "/#{cntr}/1/#{method}"
    it { put(rte).send(action, route_to("#{cntr}##{method}", :id => "1")) }
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
