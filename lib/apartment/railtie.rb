require 'rails'

module Apartment
	class Railtie < Rails::Railtie
		rake_tasks do
			load 'tasks/apartment.rake'
		end
	end
end
