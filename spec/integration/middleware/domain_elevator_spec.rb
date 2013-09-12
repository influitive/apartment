require 'spec_helper'
require 'apartment/elevators/domain'

describe Apartment::Elevators::Domain, elevator: true do

  let(:domain1)   { "http://#{db1}.com" }
  let(:domain2)   { "http://#{db2}.com" }

  it_should_behave_like "an apartment elevator"
end
