Apartment.configure do |config|
  config.excluded_models = ["Company"]
  config.tenant_names = lambda{ Company.pluck(:database) }
end
