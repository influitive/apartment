module Apartment
  module Elevators
    # Provides a rack based db switching solution based on subdomains
    # Assumes that database name should match subdomain
    class Subdomain

      def initialize(app)
        @app = app
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        database = subdomain(request)

        Apartment::Database.switch database if database

        @app.call(env)
      end

      def subdomain(request)
        request.subdomain.present? && request.subdomain || nil
      end

    end
  end
end