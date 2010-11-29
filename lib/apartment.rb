module Apartment
	establish_connection(ActiveRecord::Base.configurations["alt_#{RAILS_ENV"])
end
