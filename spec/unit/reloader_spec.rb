require 'spec_helper'

describe Apartment::Reloader do

  context "using postgresql schemas" do

    before do
      Apartment.configure do |config|
        config.excluded_models = ["Company"]
        config.use_schemas = true
      end
      Apartment::Tenant.reload!(config)
      Company.reset_table_name  # ensure we're clean
    end

    subject{ Apartment::Reloader.new(double("Rack::Application", :call => nil)) }

    it "should initialize apartment when called" do
      Company.table_name.should_not include('public.')
      subject.call(double('env'))
      Company.table_name.should include('public.')
    end
  end
end