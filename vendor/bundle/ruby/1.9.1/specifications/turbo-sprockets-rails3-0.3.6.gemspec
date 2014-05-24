# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "turbo-sprockets-rails3"
  s.version = "0.3.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Broadbent"]
  s.date = "2013-01-11"
  s.description = "Speeds up the Rails 3 asset pipeline by only recompiling changed assets"
  s.email = ["nathan.f77@gmail.com"]
  s.homepage = "https://github.com/ndbroadbent/turbo-sprockets-rails3"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Supercharge your Rails 3 asset pipeline"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sprockets>, [">= 2.0.0"])
      s.add_runtime_dependency(%q<railties>, ["< 4.0.0", "> 3.2.8"])
    else
      s.add_dependency(%q<sprockets>, [">= 2.0.0"])
      s.add_dependency(%q<railties>, ["< 4.0.0", "> 3.2.8"])
    end
  else
    s.add_dependency(%q<sprockets>, [">= 2.0.0"])
    s.add_dependency(%q<railties>, ["< 4.0.0", "> 3.2.8"])
  end
end
