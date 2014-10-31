# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "balanced"
  s.version = "0.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Mahmoud Abdelkader"]
  s.date = "2014-03-21"
  s.description = "Balanced is the payments platform for marketplaces.\n    Integrate a payments experience just like Amazon for your marketplace.\n    Forget about dealing with banking systems, compliance, fraud, and security.\n    "
  s.email = ["mahmoud@poundpay.com"]
  s.homepage = "https://balancedpayments.com"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Sign up on https://balancedpayments.com/"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<faraday>, [">= 0.8.6"])
      s.add_runtime_dependency(%q<faraday_middleware>, ["~> 0.9.0"])
    else
      s.add_dependency(%q<faraday>, [">= 0.8.6"])
      s.add_dependency(%q<faraday_middleware>, ["~> 0.9.0"])
    end
  else
    s.add_dependency(%q<faraday>, [">= 0.8.6"])
    s.add_dependency(%q<faraday_middleware>, ["~> 0.9.0"])
  end
end
