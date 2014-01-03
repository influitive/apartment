require 'apartment/elevators/subdomain'

module Apartment
  module Elevators
    # Provides a rack based tenant switching solution based on the first subdomain
    # of a given domain name.
    # eg:
    #     - example1.domain.com               => example1
    #     - example2.something.domain.com     => example2
    class FirstSubdomain < Subdomain

      def parse_tenant_name(request)
        super.split('.')[0]
      end
    end
  end
end