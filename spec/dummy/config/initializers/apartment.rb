Apartment.configure do |config|
  config.excluded_models = ["Company"]
  config.database_names = lambda{ Company.scoped.collect(&:database) }
end