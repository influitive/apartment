require 'spec_helper'
require 'apartment/elevators/generic'

describe Apartment::Elevators::Generic, elevator: true do

  # NOTE, see spec/dummy/config/application.rb to see the Proc that defines the behaviour here
  let(:domain1)   { "http://#{db1}.com?db=#{db1}" }
  let(:domain2)   { "http://#{db2}.com?db=#{db2}" }

  it_should_behave_like "an apartment elevator"
end