module Apartment
  module Adapters
    class AbstractAdapter

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

        process(tenant) do
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
        warn "[Deprecation Warning] `current_database` is now deprecated, please use `current_tenant`"
        current_tenant
      end

      #   Get the current tenant name
      #
      #   @return {String} current tenant name
      #
      def current_tenant
        Apartment.connection.current_database
      end

      #   Note alias_method here doesn't work with inheritence apparently ??
      #
      def current
        current_tenant
      end

      #   Drop the tenant
      #
      #   @param {String} tenant Database name
      #
      def drop(tenant)
        # Apartment.connection.drop_database   note that drop_database will not throw an exception, so manually execute
        Apartment.connection.execute("DROP DATABASE #{environmentify(tenant)}" )

      rescue *rescuable_exceptions
        raise DatabaseNotFound, "The tenant #{environmentify(tenant)} cannot be found"
      end

      #   Connect to tenant, do your biz, switch back to previous tenant
      #
      #   @param {String?} tenant Database or schema to connect to
      #
      def process(tenant = nil)
        previous_tenant = current_tenant
        switch(tenant)
        yield if block_given?

      ensure
        switch(previous_tenant) rescue reset
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

      #   Switch to new connection (or schema if appopriate)
      #
      #   @param {String} tenant Database name
      #
      def switch(tenant = nil)
        # Just connect to default db and return
        return reset if tenant.nil?

        connect_to_new(tenant).tap do
          ActiveRecord::Base.connection.clear_query_cache
        end
      end

      #   Load the rails seed file into the db
      #
      def seed_data
        silence_stream(STDOUT){ load_or_abort("#{Rails.root}/db/seeds.rb") } # Don't log the output of seeding the db
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
        raise DatabaseExists, "The tenant #{environmentify(tenant)} already exists."
      end

      #   Connect to new tenant
      #
      #   @param {String} tenant Database name
      #
      def connect_to_new(tenant)
        Apartment.establish_connection multi_tenantify(tenant)
        Apartment.connection.active?   # call active? to manually check if this connection is valid

      rescue *rescuable_exceptions
        raise DatabaseNotFound, "The tenant #{environmentify(tenant)} cannot be found."
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
        [ActiveRecord::StatementInvalid] + [rescue_from].flatten
      end

      #   Extra exceptions to rescue from
      #
      def rescue_from
        []
      end
    end
  end
end
