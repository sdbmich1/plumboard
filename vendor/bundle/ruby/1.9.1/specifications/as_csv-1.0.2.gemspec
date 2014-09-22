# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "as_csv"
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Fone"]
  s.date = "2013-01-15"
  s.description = "Instant CSV support for Rails"
  s.email = ["daniel@fone.net.nz"]
  s.homepage = "https://github.com/danielfone/as_csv"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Instant CSV support for Rails"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rails>, ["~> 3.2"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.12"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<rails>, ["~> 3.2"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.12"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.2"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.12"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
  end
end
