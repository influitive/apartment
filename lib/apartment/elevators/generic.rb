module Apartment
  module Elevators
    #   Provides a rack based db switching solution based on request
    #
    class Generic

      def initialize(app, processor = nil)
        @app = app
        @processor = processor || method(:process)
      end

      def call(env)
        request = ActionDispatch::Request.new(env)

        database = @processor.call(request)

        Apartment::Database.switch database if database

        @app.call(env)
      end

      def process(request)
        raise "Override"
      end
    end
  end
end
