require 'spec_helper'

describe Apartment::Elevators::Generic, :elevator => true do

  # NOTE, see spec/dummy/config/application.rb to see the Proc that defines the behaviour here
  let(:domain1)   { "http://#{database1}.com?db=#{database1}" }
  let(:domain2)   { "http://#{database2}.com?db=#{database2}" }

  it_should_behave_like "an apartment elevator"
end