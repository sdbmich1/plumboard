# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rb-notifu"
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["stereobooster"]
  s.date = "2011-05-19"
  s.description = "Notification system for windows. Trying to be Growl. Ruby wrapper around notifu (http://www.paralint.com/projects/notifu/index.html)"
  s.email = ["stereobooster@gmail.com"]
  s.homepage = "http://github.com/stereobooster/rb-notifu"
  s.require_paths = ["lib"]
  s.rubyforge_project = "rb-notifu"
  s.rubygems_version = "1.8.23"
  s.summary = "Notification system for windows. Trying to be Growl"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
