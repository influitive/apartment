require 'apartment/elevators/generic'

module Apartment
  module Elevators
    #   Provides a rack based tenant switching solution based on domain
    #   Assumes that tenant name should match domain
    #   Parses request host for second level domain, ignoring www
    #   eg. example.com       => example
    #       www.example.bc.ca => example
    #       a.example.bc.ca   => a
    #       
    #
    class Domain < Generic

      def parse_tenant_name(request)
        return nil if request.host.blank?

        request.host.match(/(www\.)?(?<sld>[^.]*)/)["sld"]
      end
    end
  end
end
