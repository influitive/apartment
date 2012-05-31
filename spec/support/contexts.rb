#   Some shared contexts for specs

shared_context "with default schema", :default_schema => true do
  let(:default_schema){ Apartment::Test.next_db }

  before do
    Apartment::Test.create_schema(default_schema)
    Apartment.default_schema = default_schema
  end

  after do
    # resetting default_schema so we can drop and any further resets won't try to access droppped schema
    Apartment.default_schema = nil
    Apartment::Test.drop_schema(default_schema)
  end
end