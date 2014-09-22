# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "delayed_paperclip"
  s.version = "2.6.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jesse Storimer", "Bert Goethals", "James Gifford", "Scott Carleton"]
  s.date = "2013-07-31"
  s.description = "Process your Paperclip attachments in the background with delayed_job, Resque or your own processor."
  s.email = "james@jamesrgifford.com"
  s.homepage = "http://github.com/jrgifford/delayed_paperclip"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Process your Paperclip attachments in the background."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<paperclip>, [">= 3.3.0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<delayed_job>, [">= 0"])
      s.add_development_dependency(%q<resque>, [">= 0"])
      s.add_development_dependency(%q<sidekiq>, [">= 0"])
    else
      s.add_dependency(%q<paperclip>, [">= 3.3.0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<delayed_job>, [">= 0"])
      s.add_dependency(%q<resque>, [">= 0"])
      s.add_dependency(%q<sidekiq>, [">= 0"])
    end
  else
    s.add_dependency(%q<paperclip>, [">= 3.3.0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<delayed_job>, [">= 0"])
    s.add_dependency(%q<resque>, [">= 0"])
    s.add_dependency(%q<sidekiq>, [">= 0"])
  end
end
