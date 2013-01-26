# -*- encoding: utf-8 -*-
$: << File.expand_path("../lib", __FILE__)
require "apartment/version"

Gem::Specification.new do |s|
  s.name = %q{apartment}
  s.version = Apartment::VERSION

  s.authors = ["Ryan Brunner", "Brad Robertson"]
  s.summary = %q{A Ruby gem for managing database multitenancy}
  s.description = %q{Apartment allows Rack applications to deal with database multitenancy through ActiveRecord}
  s.email = %w{ryan@influitive.com brad@influitive.com}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")

  s.homepage = %q{https://github.com/influitive/apartment}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]

  s.add_dependency 'activerecord',    '>= 3.1.2'   # must be >= 3.1.2 due to bug in prepared_statements
  s.add_dependency 'rack',            '>= 1.3.6'
end