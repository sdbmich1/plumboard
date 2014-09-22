$:.push File.expand_path("../lib", __FILE__)
require "delayed_paperclip/version"

Gem::Specification.new do |s|
  s.name        = %q{delayed_paperclip}
  s.version     = DelayedPaperclip::VERSION

  s.authors     = ["Jesse Storimer", "Bert Goethals", "James Gifford", "Scott Carleton"]
  s.summary     = %q{Process your Paperclip attachments in the background.}
  s.description = %q{Process your Paperclip attachments in the background with delayed_job, Resque or your own processor.}
  s.email       = %q{james@jamesrgifford.com}
  s.homepage    = %q{http://github.com/jrgifford/delayed_paperclip}

  s.add_dependency 'paperclip', [">= 3.3.0"]

  s.add_development_dependency 'mocha'
  s.add_development_dependency "rspec"
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'delayed_job'
  s.add_development_dependency 'resque'
  s.add_development_dependency 'sidekiq'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
end

