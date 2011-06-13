require 'bundler' rescue 'You must `gem install bundler` and `bundle install` to run rake tasks'
Bundler.setup
Bundler::GemHelper.install_tasks

require "rspec"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

namespace :spec do
  RSpec::Core::RakeTask.new(:tasks) do |spec|
    spec.pattern = "spec/tasks/**/*_spec.rb"
  end

  RSpec::Core::RakeTask.new(:unit) do |spec|
    spec.pattern = "spec/unit/**/*_spec.rb"
  end

  RSpec::Core::RakeTask.new(:integration) do |spec|
    spec.pattern = "spec/integration/**/*_spec.rb"
  end
end

task :default => :spec