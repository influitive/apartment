require 'apartment/deprecation'

module Apartment
  module Adapters
    class AbstractAdapter
      attr_writer :default_tenant

      #   @constructor
      #   @param {Hash} config Database config
      #
      def initialize(config)
        @config = config
      end

      #   Create a new tenant, import schema, seed if appropriate
      #
      #   @param {String} tenant Tenant name
      #
      def create(tenant)
        create_tenant(tenant)

        switch(tenant) do
          import_database_schema

          # Seed data if appropriate
          seed_data if Apartment.seed_after_create

          yield if block_given?
        end
      end

      #   Get the current tenant name
      #
      #   @return {String} current tenant name
      #
      def current_database
        Apartment::Deprecation.warn "[Deprecation Warning] `current_database` is now deprecated, please use `current`"
        current
      end

      #   Get the current tenant name
      #
      #   @return {String} current tenant name
      #
      def current_tenant
        Apartment::Deprecation.warn "[Deprecation Warning] `current_tenant` is now deprecated, please use `current`"
        current
      end

      #   Note alias_method here doesn't work with inheritence apparently ??
      #
      def current
        Apartment.connection.current_database
      end

      #   Return the original public tenant
      #
      #   @return {String} default tenant name
      #
      def default_tenant
        @default_tenant || Apartment.default_tenant
      end
      alias :default_schema :default_tenant # TODO deprecate default_schema

      #   Drop the tenant
      #
      #   @param {String} tenant name
      #
      def drop(tenant)
        # Apartment.connection.drop_database   note that drop_database will not throw an exception, so manually execute
        Apartment.connection.execute("DROP DATABASE #{environmentify(tenant)}" )

      rescue *rescuable_exceptions
        raise TenantNotFound, "The tenant #{environmentify(tenant)} cannot be found"
      end

      #   Switch to a new tenant
      #
      #   @param {String} tenant name
      #
      def switch!(tenant = nil)
        return reset if tenant.nil?

        connect_to_new(tenant).tap do
          Apartment.connection.clear_query_cache
        end
      end

      #   Connect to tenant, do your biz, switch back to previous tenant
      #
      #   @param {String?} tenant to connect to
      #
      def switch(tenant = nil)
        if block_given?
          begin
            previous_tenant = current
            switch!(tenant)
            yield

          ensure
            switch!(previous_tenant) rescue reset
          end
        else
          Apartment::Deprecation.warn("[Deprecation Warning] `switch` now requires a block reset to the default tenant after the block. Please use `switch!` instead if you don't want this")
          switch!(tenant)
        end
      end

      #   [Deprecated]
      def process(tenant = nil, &block)
        Apartment::Deprecation.warn("[Deprecation Warning] `process` is now deprecated. Please use `switch`")
        switch(tenant, &block)
      end

      #   Iterate over all tenants, switch to tenant and yield tenant name
      #
      def each(tenants = Apartment.tenant_names)
        tenants.each do |tenant|
          switch(tenant){ yield tenant }
        end
      end

      #   Establish a new connection for each specific excluded model
      #
      def process_excluded_models
        # All other models will shared a connection (at Apartment.connection_class) and we can modify at will
        Apartment.excluded_models.each do |excluded_model|
          excluded_model.constantize.establish_connection @config
        end
      end

      #   Reset the tenant connection to the default
      #
      def reset
        Apartment.establish_connection @config
      end

      #   Load the rails seed file into the db
      #
      def seed_data
        # Don't log the output of seeding the db
        silence_stream(STDOUT){ load_or_abort(Apartment.seed_data_file) } if Apartment.seed_data_file
      end
      alias_method :seed, :seed_data

    protected

      #   Create the tenant
      #
      #   @param {String} tenant Database name
      #
      def create_tenant(tenant)
        Apartment.connection.create_database( environmentify(tenant) )

      rescue *rescuable_exceptions
        raise TenantExists, "The tenant #{environmentify(tenant)} already exists."
      end

      #   Connect to new tenant
      #
      #   @param {String} tenant Database name
      #
      def connect_to_new(tenant)
        Apartment.establish_connection multi_tenantify(tenant)
        Apartment.connection.active?   # call active? to manually check if this connection is valid

      rescue *rescuable_exceptions
        raise TenantNotFound, "The tenant #{environmentify(tenant)} cannot be found."
      end

      #   Prepend the environment if configured and the environment isn't already there
      #
      #   @param {String} tenant Database name
      #   @return {String} tenant name with Rails environment *optionally* prepended
      #
      def environmentify(tenant)
        unless tenant.include?(Rails.env)
          if Apartment.prepend_environment
            "#{Rails.env}_#{tenant}"
          elsif Apartment.append_environment
            "#{tenant}_#{Rails.env}"
          else
            tenant
          end
        else
          tenant
        end
      end

      #   Import the database schema
      #
      def import_database_schema
        ActiveRecord::Schema.verbose = false    # do not log schema load output.

        load_or_abort(Apartment.database_schema_file) if Apartment.database_schema_file
      end

      #   Return a new config that is multi-tenanted
      #
      def multi_tenantify(tenant)
        @config.clone.tap do |config|
          config[:database] = environmentify(tenant)
        end
      end

      #   Load a file or abort if it doesn't exists
      #
      def load_or_abort(file)
        if File.exists?(file)
          load(file)
        else
          abort %{#{file} doesn't exist yet}
        end
      end

      #   Exceptions to rescue from on db operations
      #
      def rescuable_exceptions
        [ActiveRecord::ActiveRecordError] + Array(rescue_from)
      end

      #   Extra exceptions to rescue from
      #
      def rescue_from
        []
      end
    end
  end
end
