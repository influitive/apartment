require 'spec_helper'

describe Apartment::Config do
  
  it "should recognize default options" do
    expect {
      Apartment::Config.excluded_models
    }.to_not raise_error
  end
  
  it "should raise exception for unknown config options" do
    expect {
      Apartment::Config.some_unknown_option
    }.to raise_error
  end
end