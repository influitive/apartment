module Apartment
  module Elevators
    # Provides a rack based db switching solution based on subdomains
    # Assumes that database name should match subdomain
    class FirstSubdomain < Subdomain

      def parse_database_name(request)
        subdomain = super(request)
        subdomain && subdomain.match(/(\w+)(\.\w+)?/)[1]
      end

    end
  end
end