# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "vcr"
  s.version = "2.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.5") if s.respond_to? :required_rubygems_version=
  s.authors = ["Myron Marston"]
  s.date = "2013-05-18"
  s.description = "VCR provides a simple API to record and replay your test suite's HTTP interactions.  It works with a variety of HTTP client libraries, HTTP stubbing libraries and testing frameworks."
  s.email = "myron.marston@gmail.com"
  s.homepage = "https://github.com/vcr/vcr"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubygems_version = "1.8.23"
  s.summary = "Record your test suite's HTTP interactions and replay them during future test runs for fast, deterministic, accurate tests."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, [">= 1.0.7"])
      s.add_development_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_development_dependency(%q<cucumber>, ["~> 1.1.4"])
      s.add_development_dependency(%q<aruba>, ["~> 0.4.11"])
      s.add_development_dependency(%q<rspec>, ["~> 2.11"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.9.2"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_development_dependency(%q<webmock>, ["~> 1.10"])
      s.add_development_dependency(%q<faraday>, ["~> 0.8"])
      s.add_development_dependency(%q<httpclient>, ["~> 2.2"])
      s.add_development_dependency(%q<excon>, ["~> 0.22"])
      s.add_development_dependency(%q<timecop>, ["~> 0.3.5"])
      s.add_development_dependency(%q<rack>, ["~> 1.3.6"])
      s.add_development_dependency(%q<sinatra>, ["~> 1.3.2"])
      s.add_development_dependency(%q<multi_json>, ["~> 1.0.3"])
      s.add_development_dependency(%q<json>, ["~> 1.6.5"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.5.3"])
      s.add_development_dependency(%q<redis>, ["~> 2.2.2"])
      s.add_development_dependency(%q<typhoeus>, ["~> 0.6"])
      s.add_development_dependency(%q<patron>, ["~> 0.4.15"])
      s.add_development_dependency(%q<em-http-request>, ["~> 1.0.2"])
      s.add_development_dependency(%q<curb>, ["~> 0.8.0"])
      s.add_development_dependency(%q<yajl-ruby>, ["~> 1.1.0"])
    else
      s.add_dependency(%q<bundler>, [">= 1.0.7"])
      s.add_dependency(%q<rake>, ["~> 0.9.2"])
      s.add_dependency(%q<cucumber>, ["~> 1.1.4"])
      s.add_dependency(%q<aruba>, ["~> 0.4.11"])
      s.add_dependency(%q<rspec>, ["~> 2.11"])
      s.add_dependency(%q<shoulda>, ["~> 2.9.2"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_dependency(%q<webmock>, ["~> 1.10"])
      s.add_dependency(%q<faraday>, ["~> 0.8"])
      s.add_dependency(%q<httpclient>, ["~> 2.2"])
      s.add_dependency(%q<excon>, ["~> 0.22"])
      s.add_dependency(%q<timecop>, ["~> 0.3.5"])
      s.add_dependency(%q<rack>, ["~> 1.3.6"])
      s.add_dependency(%q<sinatra>, ["~> 1.3.2"])
      s.add_dependency(%q<multi_json>, ["~> 1.0.3"])
      s.add_dependency(%q<json>, ["~> 1.6.5"])
      s.add_dependency(%q<simplecov>, ["~> 0.5.3"])
      s.add_dependency(%q<redis>, ["~> 2.2.2"])
      s.add_dependency(%q<typhoeus>, ["~> 0.6"])
      s.add_dependency(%q<patron>, ["~> 0.4.15"])
      s.add_dependency(%q<em-http-request>, ["~> 1.0.2"])
      s.add_dependency(%q<curb>, ["~> 0.8.0"])
      s.add_dependency(%q<yajl-ruby>, ["~> 1.1.0"])
    end
  else
    s.add_dependency(%q<bundler>, [">= 1.0.7"])
    s.add_dependency(%q<rake>, ["~> 0.9.2"])
    s.add_dependency(%q<cucumber>, ["~> 1.1.4"])
    s.add_dependency(%q<aruba>, ["~> 0.4.11"])
    s.add_dependency(%q<rspec>, ["~> 2.11"])
    s.add_dependency(%q<shoulda>, ["~> 2.9.2"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
    s.add_dependency(%q<webmock>, ["~> 1.10"])
    s.add_dependency(%q<faraday>, ["~> 0.8"])
    s.add_dependency(%q<httpclient>, ["~> 2.2"])
    s.add_dependency(%q<excon>, ["~> 0.22"])
    s.add_dependency(%q<timecop>, ["~> 0.3.5"])
    s.add_dependency(%q<rack>, ["~> 1.3.6"])
    s.add_dependency(%q<sinatra>, ["~> 1.3.2"])
    s.add_dependency(%q<multi_json>, ["~> 1.0.3"])
    s.add_dependency(%q<json>, ["~> 1.6.5"])
    s.add_dependency(%q<simplecov>, ["~> 0.5.3"])
    s.add_dependency(%q<redis>, ["~> 2.2.2"])
    s.add_dependency(%q<typhoeus>, ["~> 0.6"])
    s.add_dependency(%q<patron>, ["~> 0.4.15"])
    s.add_dependency(%q<em-http-request>, ["~> 1.0.2"])
    s.add_dependency(%q<curb>, ["~> 0.8.0"])
    s.add_dependency(%q<yajl-ruby>, ["~> 1.1.0"])
  end
end
