require 'spec_helper'

describe Apartment do
  it "should be valid" do
    Apartment.should be_a(Module)
  end

  it "should be a valid app" do
    ::Rails.application.should be_a(Dummy::Application)
  end
end