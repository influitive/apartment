require 'rack/request'
require 'apartment/database'

module Apartment
  module Elevators
    #   Provides a rack based tenant switching solution based on request
    #
    class Generic

      def initialize(app, processor = nil)
        @app = app
        @processor = processor || method(:parse_tenant_name)
      end

      def call(env)
        request = Rack::Request.new(env)

        database = @processor.call(request)

        Apartment::Database.switch database if database

        @app.call(env)
      end

      def parse_database_name(request)
        warn "[DEPRECATED] - Use #parse_tenant_name"
        parse_tenant_name(request)
      end

      def parse_tenant_name(request)
        raise "Override"
      end
    end
  end
end
