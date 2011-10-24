require 'bundler' rescue 'You must `gem install bundler` and `bundle install` to run rake tasks'
Bundler.setup
Bundler::GemHelper.install_tasks

require "rspec"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

namespace :spec do
  
  [:tasks, :unit, :adapters, :integration].each do |type|
    RSpec::Core::RakeTask.new(type) do |spec|
      spec.pattern = "spec/#{type}/**/*_spec.rb"
    end
  end
  
  namespace :unit do
    RSpec::Core::RakeTask.new(:adapters) do |spec|
      spec.pattern = "spec/unit/adapters/**/*_spec.rb"
    end
  end

end

task :default => :spec

namespace :postgres do
  require 'active_record'
  require "#{File.join(File.dirname(__FILE__), 'spec', 'support', 'config')}"
  
  desc 'Build the PostgreSQL test databases'
  task :build_db do
    %x{ createdb -E UTF8 #{pg_config['database']} } rescue "test db already exists"
    ActiveRecord::Base.establish_connection pg_config
    load 'spec/dummy/db/schema.rb'
  end
  
  desc "drop the PostgreSQL test database"
  task :drop_db do
    puts "dropping database #{pg_config['database']}"
    %x{ dropdb #{pg_config['database']} }
  end
    
end

namespace :mysql do
  require 'active_record'
  require "#{File.join(File.dirname(__FILE__), 'spec', 'support', 'config')}"
  
  desc 'Build the MySQL test databases'
  task :build_db do
    %x{ mysqladmin -u root create #{my_config['database']} } rescue "test db already exists"
    ActiveRecord::Base.establish_connection my_config
    load 'spec/dummy/db/schema.rb'
  end
  
  desc "drop the MySQL test database"
  task :drop_db do
    puts "dropping database #{my_config['database']}"
    %x{ mysqladmin -u root drop #{my_config['database']} }
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
