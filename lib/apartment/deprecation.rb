require 'active_support/deprecation'

module Apartment
  module Deprecation

    def self.warn(message)
      ActiveSupport::Deprecation.warn message
    end
  end
end
