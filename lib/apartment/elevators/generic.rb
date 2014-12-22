require 'rack/request'
require 'apartment/tenant'
require 'apartment/deprecation'

module Apartment
  module Elevators
    #   Provides a rack based tenant switching solution based on request
    #
    class Generic

      def initialize(app, processor = nil)
        @app = app
        @processor = processor || parse_method
      end

      def call(env)
        request = Rack::Request.new(env)

        database = @processor.call(request)

        Apartment::Tenant.switch! database if database

        @app.call(env)
      end

      def parse_database_name(request)
        deprecation_warning
        parse_tenant_name(request)
      end

      def parse_tenant_name(request)
        raise "Override"
      end

      def parse_method
        if self.class.instance_methods(false).include? :parse_database_name
          deprecation_warning
          method(:parse_database_name)
        else
          method(:parse_tenant_name)
        end
      end

      def deprecation_warning
        Apartment::Deprecation.warn "[DEPRECATED::Apartment] Use #parse_tenant_name instead of #parse_database_name -> #{self.class.name}"
      end
    end
  end
end
