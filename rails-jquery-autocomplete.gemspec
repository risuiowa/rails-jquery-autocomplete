# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rails-jquery-autocomplete/version"

Gem::Specification.new do |s|
  s.name = %q{rails-jquery-autocomplete}
  s.version = RailsJQueryAutocomplete::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["David Padilla", "Joiey Seeley", "Sundus Yousuf"]
  s.email = %q{david@padilla.cc joiey.seeley@gmail.com sundusahmedyousuf@gmail.com}
  s.homepage = %q{https://github.com/bigtunacan/rails-jquery-autocomplete/}
  s.summary = %q{Use jQuery's autocomplete plugin with Rails 4+.}
  s.description = %q{Use jQuery's autocomplete plugin with Rails 4+.}
  s.license = %q{MIT}

  s.add_dependency('rails', '>= 3.2')

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'mongoid',      '>= 2.0.0'
  s.add_development_dependency 'mongo_mapper', '>= 0.9'
  #s.add_development_dependency 'mongo',        '~> 1.6.2'
  s.add_development_dependency 'bson_ext',     '~> 1.6.2'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-test'
  s.add_development_dependency 'test-unit-rr'
  s.add_development_dependency 'shoulda',      '~> 3.0.1'
  s.add_development_dependency 'uglifier'
  s.add_development_dependency 'simple_form',  '~>1.5'
  s.add_development_dependency 'debugger' if RUBY_VERSION < '2.0.0'
  s.add_development_dependency 'byebug' if RUBY_VERSION > '2.0.0'

  s.files         = Dir['lib/**/*'] + %w{CHANGELOG.md LICENSE README.md Rakefile}
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end

