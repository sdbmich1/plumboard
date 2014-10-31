# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "capistrano-maintenance"
  s.version = "0.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas von Deyen"]
  s.date = "2013-07-31"
  s.description = "The deploy:web tasks where removed from Capistrano core. This extension brings them back."
  s.email = "tvd@magiclabs.de"
  s.homepage = "https://github.com/tvdeyen/capistrano-maintenance"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Offers deploy:web:disable and deploy:web:enable tasks for Capistrano."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 2.0.0"])
    else
      s.add_dependency(%q<capistrano>, [">= 2.0.0"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 2.0.0"])
  end
end
