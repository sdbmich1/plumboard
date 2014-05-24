# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "database_cleaner"
  s.version = "0.9.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ben Mabey"]
  s.date = "2012-10-11"
  s.description = "Strategies for cleaning databases.  Can be used to ensure a clean state for testing."
  s.email = "ben@benmabey.com"
  s.extra_rdoc_files = ["LICENSE", "README.textile", "TODO"]
  s.files = ["LICENSE", "README.textile", "TODO"]
  s.homepage = "http://github.com/bmabey/database_cleaner"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Strategies for cleaning databases.  Can be used to ensure a clean state for testing."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<json_pure>, [">= 0"])
      s.add_development_dependency(%q<activerecord>, [">= 0"])
      s.add_development_dependency(%q<datamapper>, ["= 1.0.0"])
      s.add_development_dependency(%q<dm-migrations>, ["= 1.0.0"])
      s.add_development_dependency(%q<dm-sqlite-adapter>, ["= 1.0.0"])
      s.add_development_dependency(%q<mongoid>, [">= 0"])
      s.add_development_dependency(%q<tzinfo>, [">= 0"])
      s.add_development_dependency(%q<mongo_ext>, [">= 0"])
      s.add_development_dependency(%q<bson_ext>, [">= 0"])
      s.add_development_dependency(%q<mongo_mapper>, [">= 0"])
      s.add_development_dependency(%q<couch_potato>, [">= 0"])
      s.add_development_dependency(%q<sequel>, ["~> 3.21.0"])
      s.add_development_dependency(%q<mysql>, [">= 0"])
      s.add_development_dependency(%q<mysql2>, [">= 0"])
      s.add_development_dependency(%q<pg>, [">= 0"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<datamapper>, ["= 1.0.0"])
      s.add_dependency(%q<dm-migrations>, ["= 1.0.0"])
      s.add_dependency(%q<dm-sqlite-adapter>, ["= 1.0.0"])
      s.add_dependency(%q<mongoid>, [">= 0"])
      s.add_dependency(%q<tzinfo>, [">= 0"])
      s.add_dependency(%q<mongo_ext>, [">= 0"])
      s.add_dependency(%q<bson_ext>, [">= 0"])
      s.add_dependency(%q<mongo_mapper>, [">= 0"])
      s.add_dependency(%q<couch_potato>, [">= 0"])
      s.add_dependency(%q<sequel>, ["~> 3.21.0"])
      s.add_dependency(%q<mysql>, [">= 0"])
      s.add_dependency(%q<mysql2>, [">= 0"])
      s.add_dependency(%q<pg>, [">= 0"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<datamapper>, ["= 1.0.0"])
    s.add_dependency(%q<dm-migrations>, ["= 1.0.0"])
    s.add_dependency(%q<dm-sqlite-adapter>, ["= 1.0.0"])
    s.add_dependency(%q<mongoid>, [">= 0"])
    s.add_dependency(%q<tzinfo>, [">= 0"])
    s.add_dependency(%q<mongo_ext>, [">= 0"])
    s.add_dependency(%q<bson_ext>, [">= 0"])
    s.add_dependency(%q<mongo_mapper>, [">= 0"])
    s.add_dependency(%q<couch_potato>, [">= 0"])
    s.add_dependency(%q<sequel>, ["~> 3.21.0"])
    s.add_dependency(%q<mysql>, [">= 0"])
    s.add_dependency(%q<mysql2>, [">= 0"])
    s.add_dependency(%q<pg>, [">= 0"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
  end
end
