require 'bundler' rescue 'You must `gem install bundler` and `bundle install` to run rake tasks'
Bundler.setup
Bundler::GemHelper.install_tasks

require 'appraisal'

require "rspec"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec => %w{ db:copy_credentials db:test:prepare }) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
  # spec.rspec_opts = '--order rand:47078'
end

namespace :spec do
  [:tasks, :unit, :adapters, :integration].each do |type|
    RSpec::Core::RakeTask.new(type => :spec) do |spec|
      spec.pattern = "spec/#{type}/**/*_spec.rb"
    end
  end
end

task :console do
  require 'pry'
  require 'apartment'
  ARGV.clear
  Pry.start
end

task :default => :spec

namespace :db do
  namespace :test do
    task :prepare => %w{postgres:drop_db postgres:build_db mysql:drop_db mysql:build_db}
  end

  desc "copy sample database credential files over if real files don't exist"
  task :copy_credentials do
    require 'fileutils'
    apartment_db_file = 'spec/config/database.yml'
    rails_db_file = 'spec/dummy/config/database.yml'

    FileUtils.copy(apartment_db_file + '.sample', apartment_db_file, :verbose => true) unless File.exists?(apartment_db_file)
    FileUtils.copy(rails_db_file + '.sample', rails_db_file, :verbose => true)         unless File.exists?(rails_db_file)
  end
end

namespace :postgres do
  require 'active_record'
  require "#{File.join(File.dirname(__FILE__), 'spec', 'support', 'config')}"

  desc 'Build the PostgreSQL test databases'
  task :build_db do
    params = []
    params << "-E UTF8"
    params << pg_config['database']
    params << "-U#{pg_config['username']}"
    params << "-h#{pg_config['host']}" if pg_config['host']
    params << "-p#{pg_config['port']}" if pg_config['port']
    %x{ createdb #{params.join(' ')} } rescue "test db already exists"
    ActiveRecord::Base.establish_connection pg_config
    migrate
  end

  desc "drop the PostgreSQL test database"
  task :drop_db do
    puts "dropping database #{pg_config['database']}"
    params = []
    params << pg_config['database']
    params << "-U#{pg_config['username']}"
    params << "-h#{pg_config['host']}" if pg_config['host']
    params << "-p#{pg_config['port']}" if pg_config['port']
    %x{ dropdb #{params.join(' ')} }
  end

end

namespace :mysql do
  require 'active_record'
  require "#{File.join(File.dirname(__FILE__), 'spec', 'support', 'config')}"

  desc 'Build the MySQL test databases'
  task :build_db do
    params = []
    params << "-h #{my_config['host']}" if my_config['host']
    params << "-u #{my_config['username']}" if my_config['username']
    params << "-p#{my_config['password']}" if my_config['password']
    %x{ mysqladmin #{params.join(' ')} create #{my_config['database']} } rescue "test db already exists"
    ActiveRecord::Base.establish_connection my_config
    migrate
  end

  desc "drop the MySQL test database"
  task :drop_db do
    puts "dropping database #{my_config['database']}"
    params = []
    params << "-h #{my_config['host']}" if my_config['host']
    params << "-u #{my_config['username']}" if my_config['username']
    params << "-p#{my_config['password']}" if my_config['password']
    %x{ mysqladmin #{params.join(' ')} drop #{my_config['database']} --force}
  end

end

# TODO clean this up
def config
  Apartment::Test.config['connections']
end

def pg_config
  config['postgresql']
end

def my_config
  config['mysql']
end

def activerecord_below_5_2?
  ActiveRecord.version.release < Gem::Version.new('5.2.0')
end

def migrate
  if activerecord_below_5_2?
    ActiveRecord::Migrator.migrate('spec/dummy/db/migrate')
  else
    ActiveRecord::MigrationContext.new('spec/dummy/db/migrate').migrate
  end
end
