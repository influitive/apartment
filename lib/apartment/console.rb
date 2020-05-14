# frozen_string_literal: true

# A workaraound to get `reload!` to also call Apartment::Tenant.init
# This is unfortunate, but I haven't figured out how to hook into the reload process *after* files are reloaded

# reloads the environment
def reload!(print = true)
  # rubocop:disable Rails/Output
  puts 'Reloading...' if print
  # rubocop:enable Rails/Output

  # This triggers the to_prepare callbacks
  ActionDispatch::Callbacks.new(proc {}).call({})
  # Manually init Apartment again once classes are reloaded
  Apartment::Tenant.init
  true
end

def st(schema_name = nil)
  if schema_name.nil?
    # rubocop:disable Rails/Output
    tenant_list.each { |t| puts t }
    # rubocop:enable Rails/Output
  elsif tenant_list.include? schema_name
    Apartment::Tenant.switch!(schema_name)
  else
    # rubocop:disable Rails/Output
    puts "Tenant #{schema_name} is not part of the tenant list"
    # rubocop:enable Rails/Output
  end
end

def tenant_list
  tenant_list = [Apartment.default_tenant]
  tenant_list += Apartment.tenant_names
  tenant_list.uniq
end

def tenant_info_msg
  # rubocop:disable Rails/Output
  puts "Available Tenants: #{tenant_list}\n"
  puts "Use `st 'tenant'` to switch tenants & `tenant_list` to see list\n"
  # rubocop:enable Rails/Output
end
