require 'spec_helper'

describe Apartment::Reloader do

  context "using postgresql schemas" do

    before do
      Apartment.excluded_models = ["Company"]
      Company.reset_table_name  # ensure we're clean
    end

    subject{ Apartment::Reloader.new(mock("Rack::Application", :call => nil)) }

    it "should initialize apartment when called" do
      Company.table_name.should_not include('public.')
      subject.call(mock('env'))
      Company.table_name.should include('public.')
    end
  end


end