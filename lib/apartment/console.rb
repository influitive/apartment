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
