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
  
  desc 'Build the PostgreSQL test databases'
  task :build_databases do
    # config = ARTest.config['connections']['postgresql']
    # %x{ createdb -E UTF8 #{config['arunit']['database']} }
    # %x{ createdb -E UTF8 #{config['arunit2']['database']} }
  end
  
end