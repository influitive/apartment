# A workaraound to get `reload!` to also call Apartment::Tenant.init
# This is unfortunate, but I haven't figured out how to hook into the reload process *after* files are reloaded

# reloads the environment
def reload!(print=true)
  puts "Reloading..." if print
  # This triggers the to_prepare callbacks
  ActionDispatch::Callbacks.new(Proc.new {}).call({})
  # Manually init Apartment again once classes are reloaded
  Apartment::Tenant.init
  true
end
