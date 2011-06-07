$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require 'apartment'
require 'rspec'

# stub out rails models
require File.join(File.dirname(__FILE__), 'support', 'models')

RSpec.configure do |config|
  
  config.before do
    Rails.stub(:root).and_return '.'
  end
  
end