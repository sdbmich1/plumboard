# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rubber"
  s.version = "2.7.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Conway", "Kevin Menard"]
  s.date = "2014-02-12"
  s.description = "    The rubber plugin enables relatively complex multi-instance deployments of RubyOnRails applications to\n    Amazon's Elastic Compute Cloud (EC2).  Like capistrano, rubber is role based, so you can define a set\n    of configuration files for a role and then assign that role to as many concrete instances as needed. One\n    can also assign multiple roles to a single instance. This lets one start out with a single ec2 instance\n    (belonging to all roles), and add new instances into the mix as needed to scale specific facets of your\n    deployment, e.g. adding in instances that serve only as an 'app' role to handle increased app server load.\n"
  s.email = ["matt@conwaysplace.com", "nirvdrum@gmail.com"]
  s.executables = ["rubber"]
  s.files = ["bin/rubber"]
  s.homepage = "https://github.com/rubber/rubber"
  s.require_paths = ["lib"]
  s.rubyforge_project = "rubber"
  s.rubygems_version = "1.8.23"
  s.summary = "A capistrano plugin for managing multi-instance deployments to the cloud (ec2)"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, ["~> 2.12"])
      s.add_runtime_dependency(%q<net-ssh>, ["~> 2.6"])
      s.add_runtime_dependency(%q<thor>, [">= 0"])
      s.add_runtime_dependency(%q<clamp>, [">= 0"])
      s.add_runtime_dependency(%q<open4>, [">= 0"])
      s.add_runtime_dependency(%q<fog>, ["~> 1.6"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<test-unit>, [">= 0"])
      s.add_development_dependency(%q<shoulda-context>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<awesome_print>, [">= 0"])
    else
      s.add_dependency(%q<capistrano>, ["~> 2.12"])
      s.add_dependency(%q<net-ssh>, ["~> 2.6"])
      s.add_dependency(%q<thor>, [">= 0"])
      s.add_dependency(%q<clamp>, [">= 0"])
      s.add_dependency(%q<open4>, [">= 0"])
      s.add_dependency(%q<fog>, ["~> 1.6"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<test-unit>, [">= 0"])
      s.add_dependency(%q<shoulda-context>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<awesome_print>, [">= 0"])
    end
  else
    s.add_dependency(%q<capistrano>, ["~> 2.12"])
    s.add_dependency(%q<net-ssh>, ["~> 2.6"])
    s.add_dependency(%q<thor>, [">= 0"])
    s.add_dependency(%q<clamp>, [">= 0"])
    s.add_dependency(%q<open4>, [">= 0"])
    s.add_dependency(%q<fog>, ["~> 1.6"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<test-unit>, [">= 0"])
    s.add_dependency(%q<shoulda-context>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<awesome_print>, [">= 0"])
  end
end
