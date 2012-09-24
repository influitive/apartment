module Apartment
  module Sidekiq
    module Server
      class DatabaseMiddleware
        def call(worker_class, item, queue)
          Apartment::Database.process(item['apartment']) do
            yield
          end
        end
      end
    end
  end
end