require 'bundler' rescue 'You must `gem install bundler` and `bundle install` to run rake tasks'
Bundler.setup
Bundler::GemHelper.install_tasks

require "rspec"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

namespace :spec do
  
  [:tasks, :unit, :integration].each do |type|
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
    %x{ createdb -E UTF8 #{config['database']} } rescue "test db already exists"
    ActiveRecord::Base.establish_connection config
    load 'spec/dummy/db/schema.rb'
  end
  
  desc "drop the PostgreSQL test database"
  task :drop_db do
    puts "dropping database #{config['database']}"
    %x{ dropdb #{config['database']} }
  end
  
  def config
    Apartment::Test.config['connections']['postgresql']
  end
  
end