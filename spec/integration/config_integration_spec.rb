require 'spec_helper'

describe Apartment::Config do
  
  describe "#excluded_models" do
    it "should get excluded models from config" do
      Apartment::Config.excluded_models.should include("Company")
    end
  end
end