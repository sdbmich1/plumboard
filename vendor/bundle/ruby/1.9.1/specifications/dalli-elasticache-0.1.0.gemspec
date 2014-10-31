# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "dalli-elasticache"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aaron Suggs"]
  s.date = "2013-01-27"
  s.description = "A wrapper for Dalli with support for AWS ElastiCache Auto Discovery"
  s.email = "aaron@ktheory.com"
  s.homepage = "http://github.com/ktheory/dalli-elasticache"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Adds AWS ElastiCache Auto Discovery support to Dalli memcache client"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_runtime_dependency(%q<dalli>, [">= 1.0.0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<dalli>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<dalli>, [">= 1.0.0"])
  end
end
