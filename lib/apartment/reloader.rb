module Apartment
  class Reloader

    #   Middleware used in development to init Apartment for each request
    #   Necessary due to code reload (annoying).  When models are reloaded, they no longer have the proper table_name
    #   That is prepended with the schema (if using postgresql schemas)
    #   I couldn't figure out how to properly hook into the Rails reload process *after* files are reloaded
    #   so I've used this in the meantime.
    #
    #   Also see apartment/console for the re-definition of reload! that re-init's Apartment
    #
    def initialize(app)
      @app = app
    end

    def call(env)
      Tenant.init
      @app.call(env)
    end
  end
end
