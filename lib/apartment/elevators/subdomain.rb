require 'apartment/elevators/generic'

module Apartment
  module Elevators
    #   Provides a rack based tenant switching solution based on subdomains
    #   Assumes that tenant name should match subdomain
    #
    class Subdomain < Generic
      def self.excluded_subdomains
        @excluded_subdomains ||= []
      end

      def self.excluded_subdomains=(arg)
        @excluded_subdomains = arg
      end

      def parse_tenant_name(request)
        request_subdomain = subdomain(request.host)

        # If the domain acquired is set to be excluded, set the tenant to whatever is currently
        # next in line in the schema search path.
        tenant = if self.class.excluded_subdomains.include?(request_subdomain)
          nil
        else
          request_subdomain
        end

        tenant.presence
      end

    protected

      # *Almost* a direct ripoff of ActionDispatch::Request subdomain methods

      # Only care about the first subdomain for the database name
      def subdomain(host)
        subdomains(host).first
      end

      def subdomains(host)
        return [] unless named_host?(host)

        host.split('.')[0..-(Apartment.tld_length + 2)]
      end

      def named_host?(host)
        !(host.nil? || /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/.match(host))
      end
    end
  end
end
