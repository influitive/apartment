# frozen_string_literal: true

appraise 'rails-5-2' do
  gem 'rails', '~> 5.2.0'
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', '~> 52.0'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 52.0'
    gem 'activerecord-jdbcmysql-adapter', '~> 52.0'
  end
end

appraise 'rails-6-0' do
  gem 'rails', '~> 6.0.0'
  platforms :ruby do
    gem 'sqlite3', '~> 1.4'
  end
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', '~> 60.0'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 60.0'
    gem 'activerecord-jdbcmysql-adapter', '~> 60.0'
  end
end

appraise 'rails-6-1' do
  gem 'rails', '~> 6.1.0'
  platforms :ruby do
    gem 'sqlite3', '~> 1.4'
  end
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', '~> 61.0'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 61.0'
    gem 'activerecord-jdbcmysql-adapter', '~> 61.0'
  end
end

appraise 'rails-7-0' do
  gem 'rails', '~> 7.0.0'
  platforms :ruby do
    gem 'sqlite3', '~> 1.4'
  end
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', '~> 61.0'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 61.0'
    gem 'activerecord-jdbcmysql-adapter', '~> 61.0'
  end
end

appraise 'rails-master' do
  gem 'rails', git: 'https://github.com/rails/rails.git'
  platforms :ruby do
    gem 'sqlite3', '~> 1.4'
  end
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', '~> 61.0'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 61.0'
    gem 'activerecord-jdbcmysql-adapter', '~> 61.0'
  end
end
