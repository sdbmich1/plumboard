# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "area"
  s.version = "0.10.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jonathan Vingiano"]
  s.date = "2013-02-22"
  s.description = "Area allows you to perform a variety of conversions between places in the United States and area codes or zip codes."
  s.email = "jgv@jonathanvingiano.com"
  s.homepage = "http://github.com/jgv/area"
  s.require_paths = ["lib"]
  s.rubyforge_project = "area"
  s.rubygems_version = "1.8.23"
  s.summary = "Convert a region to area code and vice versa."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<fastercsv>, ["~> 1.5"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
    else
      s.add_dependency(%q<fastercsv>, ["~> 1.5"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
    end
  else
    s.add_dependency(%q<fastercsv>, ["~> 1.5"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
  end
end
