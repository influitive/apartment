module Apartment
  module Elevators
    # Provides a rack based db switching solution based on domain 
    # Assumes that database name should match domain
    # Parses request host for second level domain
    # eg. example.com       => example
    #     www.example.bc.ca => example
    class Domain

      def initialize(app)
        @app = app
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        database = domain(request)

        Apartment::Database.switch database if database

        @app.call(env)
      end

      def domain(request)
        return nil if request.host.blank?

        request.host.match(/(www.)?(?<sld>[^.]*)/)["sld"]
      end

    end
  end
end
