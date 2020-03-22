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
    tenant_list.each { |t| puts t }
  else
    Apartment::Tenant.switch!(schema_name) if tenant_list.include? schema_name
  end
end

def tenant_list
  tenant_list = [Apartment.default_tenant]
  Apartment::Tenant.each do |t|
    tenant_list << t
  end
  tenant_list.uniq
end
