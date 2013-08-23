require 'spec_helper'
require 'apartment/elevators/host_hash'

describe Apartment::Elevators::HostHash do

  describe "#parse_database_name" do
    it "parses the host for a domain name" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'example.com')
      elevator = Apartment::Elevators::HostHash.new(nil, 'example.com' => 'example_database')
      elevator.parse_database_name(request).should == 'example_database'
    end

    it "raises DatabaseNotFound exception if there is no host" do
      request = ActionDispatch::Request.new('HTTP_HOST' => '')
      elevator = Apartment::Elevators::HostHash.new(nil, 'example.com' => 'example_database')
      expect { elevator.parse_database_name(request) }.to raise_error(Apartment::DatabaseNotFound)
    end

    it "raises DatabaseNotFound exception if there is no database associated to current host" do
      request = ActionDispatch::Request.new('HTTP_HOST' => 'example2.com')
      elevator = Apartment::Elevators::HostHash.new(nil, 'example.com' => 'example_database')
      expect { elevator.parse_database_name(request) }.to raise_error(Apartment::DatabaseNotFound)
    end
  end
end
