# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "graylog2-resque"
  s.version = "0.5.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Conway"]
  s.date = "2012-02-20"
  s.description = "A resque failure handler that sends failures to the graylog2 log management facility "
  s.email = ["wr0ngway@yahoo.com"]
  s.homepage = ""
  s.require_paths = ["lib"]
  s.rubyforge_project = "graylog2-resque"
  s.rubygems_version = "1.8.23"
  s.summary = "A resque failure handler that sends failures to the graylog2 log management facility"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_runtime_dependency(%q<gelf>, [">= 0"])
      s.add_runtime_dependency(%q<resque>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<gelf>, [">= 0"])
      s.add_dependency(%q<resque>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<gelf>, [">= 0"])
    s.add_dependency(%q<resque>, [">= 0"])
  end
end
