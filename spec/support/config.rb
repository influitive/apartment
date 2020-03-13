# frozen_string_literal: true

require 'yaml'

module Apartment
  module Test
    def self.config
      # rubocop:disable Security/YAMLLoad
      @config ||= YAML.load(ERB.new(IO.read('spec/config/database.yml')).result)
      # rubocop:enable Security/YAMLLoad
    end
  end
end
