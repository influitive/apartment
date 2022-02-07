# frozen_string_literal: true

def st(schema_name = nil)
  if schema_name.nil?
    tenant_list.each { |t| puts t }

  elsif tenant_list.include? schema_name
    Apartment::Tenant.switch!(schema_name)
  else
    puts "Tenant #{schema_name} is not part of the tenant list"

  end
end

def tenant_list
  tenant_list = [Apartment.default_tenant]
  tenant_list += Apartment.tenant_names
  tenant_list.uniq
end

def tenant_info_msg
  puts "Available Tenants: #{tenant_list}\n"
  puts "Use `st 'tenant'` to switch tenants & `tenant_list` to see list\n"
end
