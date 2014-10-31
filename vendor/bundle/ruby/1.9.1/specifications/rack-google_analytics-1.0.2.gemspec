# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rack-google_analytics"
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jason L Perry"]
  s.date = "2011-08-18"
  s.description = "Embeds Google Analytics tracking code in the bottom of HTML documents"
  s.email = "jasper@ambethia.com"
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = ["LICENSE", "README.rdoc"]
  s.homepage = "http://github.com/ambethia/rack-google_analytics"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Google Analytics for Rack applications"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 0"])
    else
      s.add_dependency(%q<rack>, [">= 0"])
    end
  else
    s.add_dependency(%q<rack>, [">= 0"])
  end
end
