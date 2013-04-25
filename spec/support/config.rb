require 'yaml'

module Apartment
  module Test

    def self.config
      @config ||= YAML.load(ERB.new(IO.read('spec/config/database.yml')).result)
    end
  end
end