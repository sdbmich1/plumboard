# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "devise-async"
  s.version = "0.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcelo Silveira"]
  s.date = "2013-03-20"
  s.description = "Send Devise's emails in background. Supports Resque, Sidekiq, Delayed::Job and QueueClassic."
  s.email = ["marcelo@mhfs.com.br"]
  s.homepage = "https://github.com/mhfs/devise-async/"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Devise Async provides an easy way to configure Devise to send its emails asynchronously using your preferred queuing backend. It supports Resque, Sidekiq, Delayed::Job and QueueClassic."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<devise>, [">= 2.2"])
      s.add_development_dependency(%q<activerecord>, ["~> 3.2"])
      s.add_development_dependency(%q<actionpack>, ["~> 3.2"])
      s.add_development_dependency(%q<actionmailer>, ["~> 3.2"])
      s.add_development_dependency(%q<sqlite3>, ["~> 1.3"])
      s.add_development_dependency(%q<resque>, ["~> 1.20"])
      s.add_development_dependency(%q<sidekiq>, ["~> 1.2"])
      s.add_development_dependency(%q<delayed_job_active_record>, ["~> 0.3"])
      s.add_development_dependency(%q<queue_classic>, ["~> 2.0"])
      s.add_development_dependency(%q<mocha>, ["~> 0.11"])
      s.add_development_dependency(%q<minitest>, ["~> 3.0"])
    else
      s.add_dependency(%q<devise>, [">= 2.2"])
      s.add_dependency(%q<activerecord>, ["~> 3.2"])
      s.add_dependency(%q<actionpack>, ["~> 3.2"])
      s.add_dependency(%q<actionmailer>, ["~> 3.2"])
      s.add_dependency(%q<sqlite3>, ["~> 1.3"])
      s.add_dependency(%q<resque>, ["~> 1.20"])
      s.add_dependency(%q<sidekiq>, ["~> 1.2"])
      s.add_dependency(%q<delayed_job_active_record>, ["~> 0.3"])
      s.add_dependency(%q<queue_classic>, ["~> 2.0"])
      s.add_dependency(%q<mocha>, ["~> 0.11"])
      s.add_dependency(%q<minitest>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<devise>, [">= 2.2"])
    s.add_dependency(%q<activerecord>, ["~> 3.2"])
    s.add_dependency(%q<actionpack>, ["~> 3.2"])
    s.add_dependency(%q<actionmailer>, ["~> 3.2"])
    s.add_dependency(%q<sqlite3>, ["~> 1.3"])
    s.add_dependency(%q<resque>, ["~> 1.20"])
    s.add_dependency(%q<sidekiq>, ["~> 1.2"])
    s.add_dependency(%q<delayed_job_active_record>, ["~> 0.3"])
    s.add_dependency(%q<queue_classic>, ["~> 2.0"])
    s.add_dependency(%q<mocha>, ["~> 0.11"])
    s.add_dependency(%q<minitest>, ["~> 3.0"])
  end
end
