# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rinku"
  s.version = "1.7.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Vicent Marti"]
  s.date = "2012-10-11"
  s.description = "    A fast and very smart autolinking library that\n    acts as a drop-in replacement for Rails `auto_link`\n"
  s.email = "vicent@github.com"
  s.extensions = ["ext/rinku/extconf.rb"]
  s.extra_rdoc_files = ["COPYING"]
  s.files = ["COPYING", "ext/rinku/extconf.rb"]
  s.homepage = "http://github.com/vmg/rinku"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Mostly autolinking"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
