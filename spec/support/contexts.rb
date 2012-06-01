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

# Some default setup for elevator specs
shared_context "elevators", :elevator => true do
   let(:company1)  { mock_model(Company, :database => Apartment::Test.next_db).as_null_object }
   let(:company2)  { mock_model(Company, :database => Apartment::Test.next_db).as_null_object }

   let(:database1) { company1.database }
   let(:database2) { company2.database }

   let(:api)       { Apartment::Database }

   before do
     Apartment.seed_after_create = false
     Apartment.use_postgres_schemas = true

     api.create(database1)
     api.create(database2)
   end

   after do
     api.drop(database1)
     api.drop(database2)
  end
end