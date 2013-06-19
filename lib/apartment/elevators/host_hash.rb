module Apartment
  module Elevators
    #   Provides a rack based db switching solution based on hosts
    #   Uses a hash to find the corresponding database name for the host
    #
    class HostHash < Generic
      def initialize(app, hash = {}, processor = nil)
        super app, processor
        @hash = hash
      end

      def parse_database_name(request)
        raise DatabaseNotFound,
          "Cannot find database for host #{request.host}" unless @hash.has_key?(request.host)

        @hash[request.host]
      end
    end
  end
end
