# frozen_string_literal: true

# A workaround to get `reload!` to also call Apartment::Tenant.init
# This is unfortunate, but I haven't figured out how to hook into the reload process *after* files are reloaded

# reloads the environment
# rubocop:disable Style/OptionalBooleanParameter
def reload!(print = true)
  logger.info 'Reloading...' if print

  # This triggers the to_prepare callbacks
  ActionDispatch::Callbacks.new(proc {}).call({})
  # Manually init Apartment again once classes are reloaded
  Apartment::Tenant.init
  true
end
# rubocop:enable Style/OptionalBooleanParameter

def st(schema_name = nil)
  if schema_name.nil?
    tenant_list.each { |t| logger.info t }

  elsif tenant_list.include? schema_name
    Apartment::Tenant.switch!(schema_name)
  else
    logger.info "Tenant #{schema_name} is not part of the tenant list"

  end
end

def tenant_list
  tenant_list = [Apartment.default_tenant]
  tenant_list += Apartment.tenant_names
  tenant_list.uniq
end

def tenant_info_msg
  logger.info "Available Tenants: #{tenant_list}\n"
  logger.info "Use `st 'tenant'` to switch tenants & `tenant_list` to see list\n"
end
