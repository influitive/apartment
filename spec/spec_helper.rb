$LOAD_PATH.unshift(File.dirname(__FILE__))

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rspec/rails"
require 'capybara/rspec'
require 'capybara/rails'
require 'pry'

silence_warnings{ IRB = Pry }

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }


RSpec.configure do |config|

  config.include RSpec::Integration::CapybaraSessions, :type => :request

  config.before(:all) do
    # Ensure that each test starts with a clean connection
    # Necessary as some tests will leak things like current_schema into the next test
    ActiveRecord::Base.clear_all_connections!
  end

  config.after(:each) do
    Apartment.reset
  end

  config.filter_run_excluding sqlserver: true

end

# Load shared examples, must happen after configure for RSpec 3
Dir["#{File.dirname(__FILE__)}/examples/**/*.rb"].each { |f| require f }
