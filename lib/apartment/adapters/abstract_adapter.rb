module Apartment
  module Adapters
    class AbstractAdapter
      include ActiveSupport::Callbacks
      define_callbacks :create, :switch

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
        run_callbacks :create do
          create_tenant(tenant)

          switch(tenant) do
            import_database_schema

            # Seed data if appropriate
            seed_data if Apartment.seed_after_create

            yield if block_given?
          end
        end
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
        with_neutral_connection(tenant) do |conn|
          drop_command(conn, tenant)
        end

      rescue *rescuable_exceptions => exception
        raise_drop_tenant_error!(tenant, exception)
      end

      #   Switch to a new tenant
      #
      #   @param {String} tenant name
      #
      def switch!(tenant = nil)
        run_callbacks :switch do
          return reset if tenant.nil?

          connect_to_new(tenant).tap do
            Apartment.connection.clear_query_cache
          end
        end
      end

      #   Connect to tenant, do your biz, switch back to previous tenant
      #
      #   @param {String?} tenant to connect to
      #
      def switch(tenant = nil)
        begin
          previous_tenant = current
          switch!(tenant)
          yield

        ensure
          switch!(previous_tenant) rescue reset
        end
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
          process_excluded_model(excluded_model)
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
        silence_warnings{ load_or_raise(Apartment.seed_data_file) } if Apartment.seed_data_file
      end
      alias_method :seed, :seed_data

    protected

      def process_excluded_model(excluded_model)
        excluded_model.constantize.establish_connection @config
      end

      def drop_command(conn, tenant)
        # connection.drop_database   note that drop_database will not throw an exception, so manually execute
        conn.execute("DROP DATABASE #{conn.quote_table_name(environmentify(tenant))}")
      end

      #   Create the tenant
      #
      #   @param {String} tenant Database name
      #
      def create_tenant(tenant)
        with_neutral_connection(tenant) do |conn|
          create_tenant_command(conn, tenant)
        end
      rescue *rescuable_exceptions => exception
        raise_create_tenant_error!(tenant, exception)
      end

      def create_tenant_command(conn, tenant)
        conn.create_database(environmentify(tenant), @config)
      end

      #   Connect to new tenant
      #
      #   @param {String} tenant Database name
      #
      def connect_to_new(tenant)
        query_cache_enabled = ActiveRecord::Base.connection.query_cache_enabled

        Apartment.establish_connection multi_tenantify(tenant)
        Apartment.connection.active?   # call active? to manually check if this connection is valid

        Apartment.connection.enable_query_cache! if query_cache_enabled
      rescue *rescuable_exceptions => exception
        Apartment::Tenant.reset if reset_on_connection_exception?
        raise_connect_error!(tenant, exception)
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

        load_or_raise(Apartment.database_schema_file) if Apartment.database_schema_file
      end

      #   Return a new config that is multi-tenanted
      #   @param {String}  tenant: Database name
      #   @param {Boolean} with_database: if true, use the actual tenant's db name
      #                                   if false, use the default db name from the db
      def multi_tenantify(tenant, with_database = true)
        db_connection_config(tenant).tap do |config|
          if with_database
            multi_tenantify_with_tenant_db_name(config, tenant)
          end
        end
      end

      def multi_tenantify_with_tenant_db_name(config, tenant)
        config[:database] = environmentify(tenant)
      end

      #   Load a file or raise error if it doesn't exists
      #
      def load_or_raise(file)
        if File.exists?(file)
          load(file)
        else
          raise FileNotFound, "#{file} doesn't exist yet"
        end
      end
      # Backward compatibility
      alias_method :load_or_abort, :load_or_raise

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

      def db_connection_config(tenant)
        Apartment.db_config_for(tenant).clone
      end

     def with_neutral_connection(tenant, &block)
        if Apartment.with_multi_server_setup
          # neutral connection is necessary whenever you need to create/remove a database from a server.
          # example: when you use postgresql, you need to connect to the default postgresql database before you create your own.
          SeparateDbConnectionHandler.establish_connection(multi_tenantify(tenant, false))
          yield(SeparateDbConnectionHandler.connection)
          SeparateDbConnectionHandler.connection.close
        else
          yield(Apartment.connection)
        end
      end

      def reset_on_connection_exception?
        false
      end

      def raise_drop_tenant_error!(tenant, exception)
        raise TenantNotFound, "Error while dropping tenant #{environmentify(tenant)}: #{ exception.message }"
      end

      def raise_create_tenant_error!(tenant, exception)
        raise TenantExists, "Error while creating tenant #{environmentify(tenant)}: #{ exception.message }"
      end

      def raise_connect_error!(tenant, exception)
        raise TenantNotFound, "Error while connecting to tenant #{environmentify(tenant)}: #{ exception.message }"
      end

      class SeparateDbConnectionHandler < ::ActiveRecord::Base
      end
    end
  end
end
