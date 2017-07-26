require 'spec_helper'

describe Apartment do
  it "should be valid" do
    expect(Apartment).to be_a(Module)
  end

  it "should be a valid app" do
    expect(::Rails.application).to be_a(Dummy::Application)
  end
end
