require 'spec_helper'

describe Apartment::Elevators::Domain, :elevator => true do

  let(:domain1)   { "http://#{database1}.com" }
  let(:domain2)   { "http://#{database2}.com" }

  it_should_behave_like "an apartment elevator"
end
