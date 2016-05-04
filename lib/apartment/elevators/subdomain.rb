require 'apartment/elevators/generic'

module Apartment
  module Elevators
    #   Provides a rack based tenant switching solution based on subdomains
    #   Assumes that tenant name should match subdomain
    #
    class Subdomain < Generic
      def initialize(*args)
        require 'public_suffix'
        super
      end

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
        PublicSuffix.valid?(host) ? (PublicSuffix.parse(host).trd || '').split('.') : []
      end
    end
  end
end
