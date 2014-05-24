# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "active_utils"
  s.version = "1.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Shopify"]
  s.date = "2012-09-07"
  s.email = ["developers@jadedpixel.com"]
  s.homepage = "http://github.com/shopify/active_utils"
  s.require_paths = ["lib"]
  s.rubyforge_project = "active_utils"
  s.rubygems_version = "1.8.23"
  s.summary = "Common utils used by active_merchant, active_fulfillment, and active_shipping"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.11"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.11"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.11"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
