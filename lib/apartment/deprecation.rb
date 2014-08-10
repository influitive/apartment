module Apartment
  module Deprecation

    def self.warn(message)
      begin
        ActiveSupport::Deprecation.warn message
      rescue
        warn message
      end
    end

  end
end