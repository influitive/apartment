require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

require "rspec"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = "spec/**/*_spec.rb"
end

RSpec::Core::RakeTask.new('spec:tasks') do |spec|
  spec.pattern = "spec/tasks/**/*_spec.rb"
end

RSpec::Core::RakeTask.new('spec:unit') do |spec|
  spec.pattern = "spec/unit/**/*_spec.rb"
end

task :default => :spec