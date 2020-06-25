# frozen_string_literal: true

$LOAD_PATH << File.expand_path('lib', __dir__)
require 'apartment/version'

Gem::Specification.new do |s|
  s.name = 'ros-apartment'
  s.version = Apartment::VERSION

  s.authors       = ['Ryan Brunner', 'Brad Robertson', 'Rui Baltazar']
  s.summary       = 'A Ruby gem for managing database multitenancy. Apartment Gem drop in replacement'
  s.description   = 'Apartment allows Rack applications to deal with database multitenancy through ActiveRecord'
  s.email         = ['ryan@influitive.com', 'brad@influitive.com', 'rui.p.baltazar@gmail.com']
  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been
  # added into git.
  s.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      # NOTE: ignore all test related
      f.match(%r{^(test|spec|features)/})
    end
  end
  s.executables   = s.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.homepage = 'https://github.com/rails-on-services/apartment'
  s.licenses = ['MIT']

  # must be >= 3.1.2 due to bug in prepared_statements
  s.add_dependency 'activerecord',    '>= 5.0.0', '< 6.1'
  s.add_dependency 'parallel',        '< 2.0'
  s.add_dependency 'public_suffix',   '>= 2.0.5', '< 5.0'
  s.add_dependency 'rack',            '>= 1.3.6', '< 3.0'

  s.add_development_dependency 'appraisal',    '~> 2.2'
  s.add_development_dependency 'bundler',      '>= 1.3', '< 3.0'
  s.add_development_dependency 'capybara',     '~> 2.0'
  s.add_development_dependency 'rake',         '~> 13.0'
  s.add_development_dependency 'rspec',        '~> 3.4'
  s.add_development_dependency 'rspec-rails',  '~> 3.4'

  if defined?(JRUBY_VERSION)
    s.add_development_dependency 'activerecord-jdbc-adapter'
    s.add_development_dependency 'activerecord-jdbcmysql-adapter'
    s.add_development_dependency 'activerecord-jdbcpostgresql-adapter'
    s.add_development_dependency 'jdbc-mysql'
    s.add_development_dependency 'jdbc-postgres'
  else
    s.add_development_dependency 'mysql2',  '~> 0.5'
    s.add_development_dependency 'pg',      '~> 1.2'
    s.add_development_dependency 'sqlite3', '~> 1.3.6'
  end
end
