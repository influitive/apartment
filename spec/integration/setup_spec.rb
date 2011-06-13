require 'spec_helper'

describe "Setup" do
  
  it "should be a valid app" do
    ::Rails.application.should be_a(Dummy::Application)
  end
end
