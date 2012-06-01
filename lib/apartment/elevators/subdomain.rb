module Apartment
  module Elevators
    #   Provides a rack based db switching solution based on subdomains
    #   Assumes that database name should match subdomain
    #
    class Subdomain < Generic

      def process(request)
        request.subdomain.present? && request.subdomain || nil
      end
    end
  end
end