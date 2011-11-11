module Apartment
  
  class Reloader
    
    #   Middleware used in development to init Apartment for each request
    #   Necessary due to code reload (annoying).  I couldn't figure out how to properly hook into
    #   the Rails reload process *after* files are reloaded, so I've used this in the meantime.
    # 
    #   Note that this has one MAJOR caveat.  Doing  `reload!` in the console in development WILL NOT run init again
    #   Thus, excluded models will not be processed again and will be queried from the current_schema rather than public.  
    #   I hope to fix this soon
    def initialize(app)
      @app = app
    end
    
    def call(env)
      Database.init
      @app.call(env)
    end
    
  end
  
end