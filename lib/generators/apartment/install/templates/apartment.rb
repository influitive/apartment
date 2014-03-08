# Require whichever elevator you're using below here...
#
# require 'apartment/elevators/generic'
# require 'apartment/elevators/domain'
require 'apartment/elevators/subdomain'

#
# Apartment Configuration
#
Apartment.configure do |config|

  # Determines whether db:migrations will automatically
  # run apartment migrations or not. Defautls to false
  #
  # config.db_migrate_tenants = true

  # These models will not be multi-tenanted,
  # but remain in the global (public) namespace
  #
  # An example might be a Customer or Tenant model that stores each tenant information
  # ex:
  #
  # config.excluded_models = %w{Tenant}
  #
  config.excluded_models = %w{}

  # use postgres schemas?
  config.use_schemas = true

  # configure persistent schemas (E.g. hstore )
  # config.persistent_schemas = 'foo'
  # config.persistent_schemas = %w{ hstore }
  # config.persistent_schemas = {'fruit' => ['vegtables', 'public']}
  # config.persistent_schemas = lambda{|tenant| tenant.gsub('_cc\z', '_ak')}

  # add the Rails environment to database names?
  # config.prepend_environment = true
  # config.append_environment = true

  # supply list of database names for migrations to run on
  config.tenant_names = lambda{ ToDo_Tenant_Or_User_Model.pluck :database }
end

##
# Elevator Configuration

# Rails.application.config.middleware.use 'Apartment::Elevators::Generic', lambda { |request|
#   # TODO: supply generic implementation
# }

# Rails.application.config.middleware.use 'Apartment::Elevators::Domain'

Rails.application.config.middleware.use 'Apartment::Elevators::Subdomain'
