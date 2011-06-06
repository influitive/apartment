require 'rails'

module Apartment
	class Railtie < Rails::Railtie
		rake_tasks do
			load 'tasks/multi_tenant_migrate.rake'
		end
	end
end
