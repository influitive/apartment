# frozen_string_literal: true

module ActiveRecord
  module ConnectionHandling
    def connected_to_with_tenant(database: nil, role: nil, prevent_writes: false, &blk)
      connected_to_without_tenant(database: database, role: role, prevent_writes: prevent_writes) do
        Apartment::Tenant.switch!(Apartment::Tenant.current)
        yield(blk)
      end
    end

    alias connected_to_without_tenant connected_to
    alias connected_to connected_to_with_tenant
  end
end
