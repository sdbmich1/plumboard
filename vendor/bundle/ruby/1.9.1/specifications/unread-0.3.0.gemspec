# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "unread"
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Georg Ledermann"]
  s.date = "2013-03-17"
  s.description = "This gem creates a scope for unread objects and adds methods to mark objects as read "
  s.email = ["mail@georg-ledermann.de"]
  s.homepage = ""
  s.require_paths = ["lib"]
  s.rubyforge_project = "unread"
  s.rubygems_version = "1.8.23"
  s.summary = "Manages read/unread status of ActiveRecord objects"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<timecop>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<timecop>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
  end
end
