# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "github/version"

Gem::Specification.new do |s|
  s.name        = "github"
  s.version     = GitHub::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Chris Wanstrath', 'Kevin Ballard', 'Scott Chacon', 'Dr Nic Williams','Robert Qualls']
  s.email       = ["robert@robertqualls.com"]
  s.homepage    = "https://github.com/rlqualls/github-gem"
  s.summary     = "Manage github from the comand line"
  s.description = "Based on the original `github` gem command line helper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "text-hyphen", "1.0.0"
  s.add_dependency "text-format", "1.0.0"
  s.add_dependency "highline", "~> 1.6"
  s.add_dependency "json_pure", "~> 1.5.1"
  s.add_dependency "launchy", "~> 2.0.2"
  s.add_dependency "paint", "~> 0.8"
  s.add_dependency "rouge", "~> 1.3.2"
  s.add_dependency "ncurses-ruby", "~> 1.2.4"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~>1.3.1"
  s.add_development_dependency "activerecord", "~>3.0.0"
  s.add_development_dependency "simplecov", "~> 0.8"
end
