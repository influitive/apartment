module Apartment
	db_name = "alt_#{RAILS_ENV}"
	logger.info "Apartment overriding database to #{db_name}"
	establish_connection(db_name)
end
