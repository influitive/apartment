require 'apartment/elevators/generic'

module Apartment
  module Elevators
    #   Provides a rack based tenant switching solution based on the host
    #   Assumes that tenant name should match host
    #   Strips/ignores first subdomains in ignored_first_subdomains
    #   eg. example.com       => example.com
    #       www.example.bc.ca => www.example.bc.ca
    #   if ignored_first_subdomains = ['www']
    #       www.example.bc.ca => example.bc.ca
    #       www.a.b.c.d.com   => a.b.c.d.com
    #
    class Host < Generic
      def self.ignored_first_subdomains
        @ignored_first_subdomains ||= []
      end

      def self.ignored_first_subdomains=(arg)
        @ignored_first_subdomains = arg
      end

      def parse_tenant_name(request)
        return nil if request.host.blank?
        parts = request.host.split('.')
        self.class.ignored_first_subdomains.include?(parts[0]) ? parts.drop(1).join('.') : request.host
      end
    end
  end
end