# frozen_string_literal: true

Apartment.configure do |config|
  config.excluded_models = ['Company']
  config.tenant_names = -> { Company.pluck(:database) }
end
