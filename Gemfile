source 'http://rubygems.org'

gemspec

gem 'rails',        '>= 3.1.2'
gem 'rake',         '~> 0.9'
gem 'rspec',        '~> 2.11'
gem 'rspec-rails',  '~> 2.11'
gem 'capybara',     '~> 1.0.0'
gem 'delayed_job',  '~> 3.0'
gem 'delayed_job_active_record'

platform :ruby do
  gem 'mysql2', '~> 0.3.10'
  gem 'pg',     '>= 0.11.0'
end

platform :jruby do
  gem 'activerecord-jdbc-adapter'
  gem 'activerecord-jdbcpostgresql-adapter'
  gem 'activerecord-jdbcmysql-adapter'
  gem 'jdbc-postgres', '9.2.1002'
  gem 'jdbc-mysql'
  gem 'jruby-openssl'
end

group :local do
  gem 'pry'
  gem 'librarian-chef'
  gem 'vagrant-librarian'
end