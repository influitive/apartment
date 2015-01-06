$LOAD_PATH.unshift(File.dirname(__FILE__))

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require "rspec/rails"
require 'capybara/rspec'
require 'capybara/rails'

begin
  require 'pry'
  silence_warnings{ IRB = Pry }
rescue LoadError
end

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|

  config.include RSpec::Integration::CapybaraSessions, type: :request
  config.include Apartment::Spec::Setup

  # Somewhat brutal hack so that rails 4 postgres extensions don't modify this file
  config.after(:all) do
    `git checkout -- spec/dummy/db/schema.rb`
  end
end

# Load shared examples, must happen after configure for RSpec 3
Dir["#{File.dirname(__FILE__)}/examples/**/*.rb"].each { |f| require f }
