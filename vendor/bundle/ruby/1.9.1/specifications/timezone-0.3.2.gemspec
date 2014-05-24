# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "timezone"
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pan Thomakos"]
  s.date = "2014-04-15"
  s.description = "A simple way to get accurate current and historical timezone information based on zone or latitude and longitude coordinates. This gem uses the tz database (http://www.twinsun.com/tz/tz-link.htm) for historical timezone information. It also uses the geonames API for timezone latitude and longitude lookup (http://www.geonames.org/export/web-services.html)."
  s.email = ["pan.thomakos@gmail.com"]
  s.extra_rdoc_files = ["README.markdown", "License.txt"]
  s.files = ["README.markdown", "License.txt"]
  s.homepage = "http://github.com/panthomakos/timezone"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "timezone"
  s.rubygems_version = "1.8.23"
  s.summary = "timezone-0.3.2"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<minitest>, ["~> 4.0"])
      s.add_development_dependency(%q<timecop>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<minitest>, ["~> 4.0"])
      s.add_dependency(%q<timecop>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<minitest>, ["~> 4.0"])
    s.add_dependency(%q<timecop>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
