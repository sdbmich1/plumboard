# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "open_uri_redirections"
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jaime Iniesta", "Gabriel Cebrian"]
  s.date = "2013-11-19"
  s.description = "OpenURI patch to allow redirections between HTTP and HTTPS"
  s.email = ["jaimeiniesta@gmail.com"]
  s.homepage = "https://github.com/jaimeiniesta/open_uri_redirections"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "OpenURI patch to allow redirections between HTTP and HTTPS"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.13.0"])
      s.add_development_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_development_dependency(%q<rake>, ["~> 10.0.3"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.13.0"])
      s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
      s.add_dependency(%q<rake>, ["~> 10.0.3"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.13.0"])
    s.add_dependency(%q<fakeweb>, ["~> 1.3.0"])
    s.add_dependency(%q<rake>, ["~> 10.0.3"])
  end
end
