appraise "rails-4-2" do
  gem "rails", "~> 4.2.0"
  platforms :ruby do
    gem "pg", "< 1.0.0"
    gem "mysql2", "~> 0.4.0"
  end
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', '~> 1.3'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3'
    gem 'activerecord-jdbcmysql-adapter', '~> 1.3'
  end
end

appraise "rails-5-0" do
  gem "rails", "~> 5.0.0"
  platforms :ruby do
    gem "pg", "< 1.0.0"
  end
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', '~> 50.0'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 50.0'
    gem 'activerecord-jdbcmysql-adapter', '~> 50.0'
  end
end

appraise "rails-5-1" do
  gem "rails", "~> 5.1.0"
  platforms :ruby do
    gem "pg", "< 1.0.0"
  end
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', '~> 51.0'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 51.0'
    gem 'activerecord-jdbcmysql-adapter', '~> 51.0'
  end
end

appraise "rails-5-2" do
  gem "rails", "~> 5.2.0"
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', '~> 51.0'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 51.0'
    gem 'activerecord-jdbcmysql-adapter', '~> 51.0'
  end
end

appraise "rails-master" do
  gem "rails", git: 'https://github.com/rails/rails.git'
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', '~> 51.0'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 51.0'
    gem 'activerecord-jdbcmysql-adapter', '~> 51.0'
  end
end
