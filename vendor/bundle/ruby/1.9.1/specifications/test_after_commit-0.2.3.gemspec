# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "test_after_commit"
  s.version = "0.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Michael Grosser"]
  s.date = "2014-03-13"
  s.email = "michael@grosser.it"
  s.homepage = "https://github.com/grosser/test_after_commit"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "makes after_commit callbacks testable in Rails 3+ with transactional_fixtures"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
