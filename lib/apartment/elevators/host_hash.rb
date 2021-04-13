# frozen_string_literal: true

require 'apartment/elevators/generic'

module Apartment
  module Elevators
    #   Provides a rack based tenant switching solution based on hosts
    #   Uses a hash to find the corresponding tenant name for the host
    #
    class HostHash < Generic
      def initialize(app, hash = {}, processor = nil)
        super app, processor
        @hash = hash
      end

      def parse_tenant_name(request)
        unless @hash.key?(request.host)
          raise TenantNotFound,
                "Cannot find tenant for host #{request.host}"
        end

        @hash[request.host]
      end
    end
  end
end
