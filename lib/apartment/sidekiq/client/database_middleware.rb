module Apartment
  module Sidekiq
    module Client
      class DatabaseMiddleware
        def call(worker_class, item, queue)
          item["apartment"] = Apartment::Database.current_database
          yield
        end
      end
    end
  end
end