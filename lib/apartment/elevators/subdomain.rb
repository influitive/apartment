module Apartment
  module Elevators
    #   Provides a rack based db switching solution based on subdomains
    #   Assumes that database name should match subdomain
    #
    class Subdomain < Generic

      def parse_database_name(request)
        request.subdomain.present? && request.subdomain || nil
      end
    end
  end
end