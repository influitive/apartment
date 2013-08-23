require 'spec_helper'
require 'apartment/elevators/generic'

describe Apartment::Elevators::Subdomain, :elevator => true do

  let(:domain1)   { "http://#{database1}.example.com" }
  let(:domain2)   { "http://#{database2}.example.com" }

  it_should_behave_like "an apartment elevator"
end