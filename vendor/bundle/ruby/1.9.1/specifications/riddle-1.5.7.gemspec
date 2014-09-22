# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "riddle"
  s.version = "1.5.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pat Allan"]
  s.date = "2013-07-08"
  s.description = "A Ruby API and configuration helper for the Sphinx search service."
  s.email = ["pat@freelancing-gods.com"]
  s.homepage = "http://pat.github.com/riddle/"
  s.require_paths = ["lib"]
  s.rubyforge_project = "riddle"
  s.rubygems_version = "1.8.23"
  s.summary = "An API for Sphinx, written in and for Ruby."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0.9.2"])
      s.add_development_dependency(%q<rspec>, [">= 2.5.0"])
      s.add_development_dependency(%q<yard>, [">= 0.7.2"])
    else
      s.add_dependency(%q<rake>, [">= 0.9.2"])
      s.add_dependency(%q<rspec>, [">= 2.5.0"])
      s.add_dependency(%q<yard>, [">= 0.7.2"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.9.2"])
    s.add_dependency(%q<rspec>, [">= 2.5.0"])
    s.add_dependency(%q<yard>, [">= 0.7.2"])
  end
end
