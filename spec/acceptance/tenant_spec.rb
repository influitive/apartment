require 'spec_helper'

describe Apartment::Tenant do

  shared_examples_for "a multitenancy gem" do
    context "database pooling" do
      before {
        subject.reload!(config.merge(pool: 1))
        subject.create(db1)
      }
      after  { subject.drop(db1) }

      it "resets the adapter when checking out a new connection" do
        ActiveRecord::Base.connection_pool.with_connection do
          subject.switch!(db1)
        end
        ActiveRecord::Base.connection_pool.with_connection do
          expect(subject.current).to eq(subject.default_tenant)
        end
      end
    end
  end

  context "mysql", database: :mysql do
    it_behaves_like "a multitenancy gem"
  end

  context "postgresql", database: :postgresql do
    it_behaves_like "a multitenancy gem"
  end
end
