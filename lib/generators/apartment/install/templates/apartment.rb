#
# Apartment Configuration
#
Apartment.configure do |config|

  # these models will not be multi-tenanted,
  # but remain in the global (public) namespace
  config.excluded_models = %w{
    ActiveRecord::SessionStore::Session
  }

  # use postgres schemas?
  config.use_schemas = true

  # configure persistent schemas (E.g. hstore )
  # config.persistent_schemas = %w{ hstore }

  # add the Rails environment to database names?
  # config.prepend_environment = true
  # config.append_environment = true

  # supply list of database names for migrations to run on
  config.database_names = lambda{ ToDo_Tenant_Or_User_Model.pluck :database }

end

##
# Elevator Configuration

# Rails.application.config.middleware.use 'Apartment::Elevators::Generic', lambda { |request|
#   # TODO: supply generic implementation
# }

# Rails.application.config.middleware.use 'Apartment::Elevators::Domain'

Rails.application.config.middleware.use 'Apartment::Elevators::Subdomain'
