# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "parsley-rails"
  s.version = "1.2.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jiri Pospisil"]
  s.date = "2014-02-27"
  s.description = "Parsley.js bundled for Rails Asset Pipeline"
  s.email = ["mekishizufu@gmail.com"]
  s.homepage = "https://github.com/mekishizufu/parsley-rails"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Parsley.js bundled for Rails Asset Pipeline"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, [">= 3.0.0"])
    else
      s.add_dependency(%q<railties>, [">= 3.0.0"])
    end
  else
    s.add_dependency(%q<railties>, [">= 3.0.0"])
  end
end
