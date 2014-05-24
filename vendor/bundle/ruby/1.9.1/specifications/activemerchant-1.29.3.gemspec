# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "activemerchant"
  s.version = "1.29.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tobias Luetke"]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDNjCCAh6gAwIBAgIBADANBgkqhkiG9w0BAQUFADBBMRMwEQYDVQQDDApjb2R5\nZmF1c2VyMRUwEwYKCZImiZPyLGQBGRYFZ21haWwxEzARBgoJkiaJk/IsZAEZFgNj\nb20wHhcNMDcwMjIyMTcyMTI3WhcNMDgwMjIyMTcyMTI3WjBBMRMwEQYDVQQDDApj\nb2R5ZmF1c2VyMRUwEwYKCZImiZPyLGQBGRYFZ21haWwxEzARBgoJkiaJk/IsZAEZ\nFgNjb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC6T4Iqt5iWvAlU\niXI6L8UO0URQhIC65X/gJ9hL/x4lwSl/ckVm/R/bPrJGmifT+YooFv824N3y/TIX\n25o/lZtRj1TUZJK4OCb0aVzosQVxBHSe6rLmxO8cItNTMOM9wn3thaITFrTa1DOQ\nO3wqEjvW2L6VMozVfK1MfjL9IGgy0rCnl+2g4Gh4jDDpkLfnMG5CWI6cTCf3C1ye\nytOpWgi0XpOEy8nQWcFmt/KCQ/kFfzBo4QxqJi54b80842EyvzWT9OB7Oew/CXZG\nF2yIHtiYxonz6N09vvSzq4CvEuisoUFLKZnktndxMEBKwJU3XeSHAbuS7ix40OKO\nWKuI54fHAgMBAAGjOTA3MAkGA1UdEwQCMAAwCwYDVR0PBAQDAgSwMB0GA1UdDgQW\nBBR9QQpefI3oDCAxiqJW/3Gg6jI6qjANBgkqhkiG9w0BAQUFAAOCAQEAs0lX26O+\nHpyMp7WL+SgZuM8k76AjfOHuKajl2GEn3S8pWYGpsa0xu07HtehJhKLiavrfUYeE\nqlFtyYMUyOh6/1S2vfkH6VqjX7mWjoi7XKHW/99fkMS40B5SbN+ypAUst+6c5R84\nw390mjtLHpdDE6WQYhS6bFvBN53vK6jG3DLyCJc0K9uMQ7gdHWoxq7RnG92ncQpT\nThpRA+fky5Xt2Q63YJDnJpkYAz79QIama1enSnd4jslKzSl89JS2luq/zioPe/Us\nhbyalWR1+HrhgPoSPq7nk+s2FQUBJ9UZFK1lgMzho/4fZgzJwbu+cO8SNuaLS/bj\nhPaSTyVU0yCSnw==\n-----END CERTIFICATE-----\n"]
  s.date = "2012-12-07"
  s.description = "Active Merchant is a simple payment abstraction library used in and sponsored by Shopify. It is written by Tobias Luetke, Cody Fauser, and contributors. The aim of the project is to feel natural to Ruby users and to abstract as many parts as possible away from the user to offer a consistent interface across all supported gateways."
  s.email = "tobi@leetsoft.com"
  s.homepage = "http://activemerchant.org/"
  s.require_paths = ["lib"]
  s.rubyforge_project = "activemerchant"
  s.rubygems_version = "1.8.23"
  s.summary = "Framework and tools for dealing with credit card transactions."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3.14"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_runtime_dependency(%q<money>, [">= 0"])
      s.add_runtime_dependency(%q<builder>, [">= 2.0.0"])
      s.add_runtime_dependency(%q<json>, [">= 1.5.1"])
      s.add_runtime_dependency(%q<active_utils>, [">= 1.0.2"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<mocha>, ["~> 0.11.3"])
      s.add_development_dependency(%q<rails>, [">= 2.3.14"])
      s.add_development_dependency(%q<thor>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.3.14"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<money>, [">= 0"])
      s.add_dependency(%q<builder>, [">= 2.0.0"])
      s.add_dependency(%q<json>, [">= 1.5.1"])
      s.add_dependency(%q<active_utils>, [">= 1.0.2"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<mocha>, ["~> 0.11.3"])
      s.add_dependency(%q<rails>, [">= 2.3.14"])
      s.add_dependency(%q<thor>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.3.14"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<money>, [">= 0"])
    s.add_dependency(%q<builder>, [">= 2.0.0"])
    s.add_dependency(%q<json>, [">= 1.5.1"])
    s.add_dependency(%q<active_utils>, [">= 1.0.2"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<mocha>, ["~> 0.11.3"])
    s.add_dependency(%q<rails>, [">= 2.3.14"])
    s.add_dependency(%q<thor>, [">= 0"])
  end
end
