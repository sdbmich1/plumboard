# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rack-oauth2"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["nov matake"]
  s.date = "2012-10-13"
  s.description = "OAuth 2.0 Server & Client Library. Both Bearer and MAC token type are supported."
  s.email = "nov@matake.jp"
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = ["LICENSE", "README.rdoc"]
  s.homepage = "http://github.com/nov/rack-oauth2"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "OAuth 2.0 Server & Client Library - Both Bearer and MAC token type are supported"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rack>, [">= 1.1"])
      s.add_runtime_dependency(%q<multi_json>, [">= 1.3.6"])
      s.add_runtime_dependency(%q<httpclient>, [">= 2.2.0.2"])
      s.add_runtime_dependency(%q<activesupport>, [">= 2.3"])
      s.add_runtime_dependency(%q<i18n>, [">= 0"])
      s.add_runtime_dependency(%q<attr_required>, [">= 0.0.5"])
      s.add_development_dependency(%q<rake>, [">= 0.8"])
      s.add_development_dependency(%q<cover_me>, [">= 1.2.0"])
      s.add_development_dependency(%q<rspec>, [">= 2"])
      s.add_development_dependency(%q<webmock>, [">= 1.6.2"])
    else
      s.add_dependency(%q<rack>, [">= 1.1"])
      s.add_dependency(%q<multi_json>, [">= 1.3.6"])
      s.add_dependency(%q<httpclient>, [">= 2.2.0.2"])
      s.add_dependency(%q<activesupport>, [">= 2.3"])
      s.add_dependency(%q<i18n>, [">= 0"])
      s.add_dependency(%q<attr_required>, [">= 0.0.5"])
      s.add_dependency(%q<rake>, [">= 0.8"])
      s.add_dependency(%q<cover_me>, [">= 1.2.0"])
      s.add_dependency(%q<rspec>, [">= 2"])
      s.add_dependency(%q<webmock>, [">= 1.6.2"])
    end
  else
    s.add_dependency(%q<rack>, [">= 1.1"])
    s.add_dependency(%q<multi_json>, [">= 1.3.6"])
    s.add_dependency(%q<httpclient>, [">= 2.2.0.2"])
    s.add_dependency(%q<activesupport>, [">= 2.3"])
    s.add_dependency(%q<i18n>, [">= 0"])
    s.add_dependency(%q<attr_required>, [">= 0.0.5"])
    s.add_dependency(%q<rake>, [">= 0.8"])
    s.add_dependency(%q<cover_me>, [">= 1.2.0"])
    s.add_dependency(%q<rspec>, [">= 2"])
    s.add_dependency(%q<webmock>, [">= 1.6.2"])
  end
end
